require "bigdecimal"

module FineAnts
  module Adapters
    class Betterment
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://wwws.betterment.com/app/login"
        fill_in "web_authentication[email]", :with => @user
        fill_in "web_authentication[password]", :with => @password
        click_button "Log in"
        verify_login!
      end

      def download
        accounts = all(".sub-account")
        accounts.map do |account|
          {
            :adapter => :betterment,
            :user => @user,
            :id => id_for(account),
            :name => name_for(account),
            :amount => total_for(account)
          }
        end.tap do
          find(".dropdown .user-option").click
          click_button "Log Out"
        end
      end

    private

      def verify_login!
        find ".total-balance"
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def id_for(account)
        link = account.find(".donut-label a")
        link[:href].match(/\/app\/goals\/(\d+)\//)[1]
      end

      def name_for(account)
        "#{account.find(".type-and-plan").text} - #{account.find(".goal-name").text}"
      end

      def total_for(account)
        total_string = account.find(".current-balance h3").text
        BigDecimal.new(total_string.match(/\$(.*)$/)[1].gsub(/,/,''))
      end
    end
  end
end



