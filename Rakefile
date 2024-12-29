# frozen_string_literal: true

require 'active_record'
require 'sinatra/activerecord/rake'

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:production)
