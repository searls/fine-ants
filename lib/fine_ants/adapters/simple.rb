require "bigdecimal"

module FineAnts
  module Adapters
    class Simple
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.simple.com"
        click_link "Log In"

        fill_in "login_username", :with => @user
        fill_in "login_password", :with => @password
        click_button "Sign In"
        begin
          find_field "Enter 4-digit code"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in "Enter 4-digit code", :with => answer
        click_button "Verify"
      end

      def download
        user_name = find(".masthead-username").text
        balance = find_all(".balances-item-value").first.text
        available_balance = find(".balances-sts .amount").text.strip

        [
          {
            :adapter => :simple,
            :user => @user,
            :id => "#{user_name}",
            :name => "#{user_name}",
            :amount => parse_currency(balance),
            :available_amount => parse_currency(available_balance),
          }
        ].tap{ logout! }
      end

      private
      def logout!
        visit "https://bank.simple.com/signout"
      end

      def parse_currency(currency_string)
        BigDecimal.new(currency_string.match(/\$?(.*)$/)[1].delete(","))
      end

      def verify_login!
        find("h2", text: "Safe-to-Spend")
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end

