require "capybara/dsl"

require "fine_ants/adapters/vanguard"
require "fine_ants/adapters/pnc"
require "fine_ants/adapters/betterment"
require "fine_ants/adapters/chase"

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
