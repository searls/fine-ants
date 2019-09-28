# Users can set up Capybara however they like
# But since the defaults aren't really helpful,
# We'll set it up ourselves at require-time.
# Users are free to change it after that

require "capybara"

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.default_driver = :selenium
Capybara.default_max_wait_time = 10
