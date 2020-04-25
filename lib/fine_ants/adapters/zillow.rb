require "bigdecimal"

module FineAnts
  module Adapters
    class Zillow
      def initialize(credentials)
        @user = credentials[:user]
      end

      def login
        true # No login necessary
      end

      def download
        visit "https://www.zillow.com/homedetails/total_nonsense/#{@user}_zpid/?fullpage=true"
        zestimate = find_first(
          ".estimates .home-summary-row:nth-child(2) span:nth-child(2)",
          ".zestimate.primary-quote"
        ).text.match(/(\$.*)/)[1]

        [{
          adapter: :zillow,
          user: @user,
          id: @user,
          name: find_first(".addr h1", ".hdp-home-header-st-addr").text,
          amount: BigDecimal(zestimate.gsub(/[\$,]/, ""))
        }]
      end

      private

      def find_first(*locators)
        locators.each do |locator|
          return find(locator)
        rescue Capybara::ElementNotFound
        end
      end
    end
  end
end
