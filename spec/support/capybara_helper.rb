require 'capybara/poltergeist'
require 'support/monkeypatch_poltergeist'

Billy.configure do |c|
  c.cache = true
  c.logger = Logger.new("log/test.log")
  # c.ignore_params = [
  #   "http://www.google-analytics.com/__utm.gif",
  # ]

  c.persist_cache = true
  c.non_successful_cache_disabled = false
  c.non_successful_error_level = :warn
  c.cache_request_headers = false
  c.cache_path = 'spec/request_cache/' # This path must be listed in .gitignore, to ensure private requests are not committed.
end

Capybara.configure do |config|
  config.run_server = true

  # :selenium_chrome_billy works but it opens a browser
  # :poltergeist_billy seems to work well, and is headless
  # There is this note on puffing-billy's README:
    # Note: :poltergeist_billy doesn't support proxying any localhosts, so you must
    # use :webkit_billy for headless specs when using puffing-billy for other local
    # rack apps. See this phantomjs issue for any updates.
  config.default_driver = :poltergeist_billy
  config.app = 'fake app name'
end

server = Capybara.current_session.server
Billy.config.whitelist = ["#{server.host}:#{server.port}"]
