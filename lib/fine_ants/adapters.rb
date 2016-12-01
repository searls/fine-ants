require "capybara/dsl"

# Autoload all predefined adapters
Dir[File.join(File.dirname(__FILE__), 'adapters', '*.rb')].each { |f| require f }

module FineAnts
  module Adapters
    def self.look_up(name)
      const_name = name.to_s.gsub(/_/, ' ').split(' ').map(&:capitalize).join
      const_get(const_name).tap do |adapter|
        adapter.class_eval do
          include Capybara::DSL
        end
      end
    end
  end
end
