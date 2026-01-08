# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

RubyLLM.configure do |config|
  config.ollama_api_base = ENV.fetch("OLLAMA_API_BASE", "http://localhost:11434")

  config.gemini_api_key = ENV.fetch("GEMINI_API_KEY", "test-api-key")

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("cassettes", __dir__)
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [ :method, :uri, :body ]
  }

  config.filter_sensitive_data("<GEMINI_API_KEY>") { RubyLLM.config.gemini_api_key }
  config.filter_sensitive_data("<OLLAMA_API_BASE>") { RubyLLM.config.ollama_api_base }
end

# Allow WebMock outside of VCR cassettes for alert tests
WebMock.allow_net_connect!
