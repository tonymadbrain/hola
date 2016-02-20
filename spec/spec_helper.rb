require File.expand_path '../../app.rb', __FILE__
require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'shoulda/matchers'

set :environment, :test

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!
# Disable DEBUG mode in tests
ActiveRecord::Base.logger = nil unless ENV['LOG'] == true

RSpec.configure do |config|
  # config.include RSpecMixin

  config.include Rack::Test::Methods

  # Rails cast tutorial
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end

def app
  Sinatra::Application
end
