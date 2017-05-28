# The next line is the usual require. But this file does the same thing, with a monkeypatch.
# require 'billy/capybara/rspec'

# Monkeypatch the poltergeist driver to not complain about js errors
require 'capybara/rspec'
require 'billy/browsers/capybara'
require 'billy/init/rspec'
module Billy
  module Browsers
    class Capybara
      private

      def self.register_poltergeist_driver
        ::Capybara.register_driver :poltergeist_billy do |app|
          options = {
            phantomjs_options: [
              '--ignore-ssl-errors=yes',
              "--proxy=#{Billy.proxy.host}:#{Billy.proxy.port}"
            ],
            # TODO: Submit a PR to puffing-billy to allow passing in options, so we can eliminate this monkey patch.
            js_errors: false,
          }
          ::Capybara::Poltergeist::Driver.new(app, options)
        end
      end
    end
  end
end
Billy::Browsers::Capybara.register_drivers
