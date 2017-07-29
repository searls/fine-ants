require "bigdecimal"

module FineAnts
  module Adapters
    class Zillow
      def initialize(credentials)
        @user = credentials[:user]
      end

      def login
        return true # No login necessary
      end

      def download
        visit "https://www.zillow.com/homedetails/total_nonsense/#{@user}_zpid/?fullpage=true"
        zestimate = find('.estimates .home-summary-row:nth-child(2) span:nth-child(2)').text
        [{
          :adapter => :zillow,
          :user => @user,
          :id => @user,
          :name => find('.addr h1').text,
          :amount => BigDecimal.new(zestimate.gsub(/[\$,]/,''))
        }]
      end
    end
  end
end




