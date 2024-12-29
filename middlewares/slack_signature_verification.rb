# frozen_string_literal: true

class SlackSignatureVerification
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    response = JSON.parse verify_signature(request)
    unless response['is_success']
      return [response['status_code'], { 'Content-Type' => 'application/json' },
              [response['message']]]
    end

    @app.call(env)
  end

  private

  def verify_signature(request)
    timestamp = request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
    slack_signature = request.env['HTTP_X_SLACK_SIGNATURE']
    body = request.body.read

    if timestamp.nil? || slack_signature.nil? || timestamp.to_i < Time.now.to_i - 60 * 5
      return {
        is_success: false,
        status_code: 400,
        message: 'Unknown signature or timestamp'
      }.to_json
    end

    sig_basestring = "v0:#{timestamp}:#{body}"
    computed_signature = "v0=#{OpenSSL::HMAC.hexdigest('SHA256', ENV['SLACK_SIGNING_SECRET'], sig_basestring)}"
    is_valid_signature = Rack::Utils.secure_compare(computed_signature, slack_signature)

    unless is_valid_signature
      return {
        is_success: false,
        status_code: 403,
        message: 'Invalid signature'
      }.to_json
    end

    {
      is_success: true
    }.to_json
  end
end
