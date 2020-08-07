require "bundler/setup"
require "htmlcsstoimage"
require "webmock"
require "vcr"
require "pry"
require "pry-byebug"

HCTI_USER_ID = ENV["HCTI_USER_ID"] || "user-id"
HCTI_API_KEY = ENV["HCTI_API_KEY"] || "api-key"
AUTH_HEADER = Base64.strict_encode64("#{HCTI_USER_ID}:#{HCTI_API_KEY}")

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'cassettes'
  c.filter_sensitive_data('authentication-header') { AUTH_HEADER }
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :once, match_requests_on: [:method, :uri, :body, :query] }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
