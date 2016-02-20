require 'rack/test'
require 'rspec'
require 'database_cleaner'
require File.expand_path '../../app.rb', __FILE__
require 'shoulda/matchers'

set :environment, :test

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!
# Disable DEBUG mode in tests
ActiveRecord::Base.logger = nil unless ENV['LOG'] == true

# module RSpecMixin
#   include Rack::Test::Methods
#   def app() Sinatra::Application end
# end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
  end
end

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

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end  
end

def app
  Sinatra::Application
end
