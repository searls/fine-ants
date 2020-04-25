require "bigdecimal"

module FineAnts
  module Adapters
    class UfbDirect
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://onlinebanking.ufbdirect.com/auth/login"
        sleep 2
        click_link "Login"
        sleep 2
        fill_in "Username", with: @user
        fill_in "Password", with: @password
        sleep 1
        click_button "Login"
        begin
          find ".multi-factor"
          click_button "btn-sms"
          false
        rescue Capybara::ElementNotFound
          verify_login!
          true
        end
      end

      def two_factor_response(answer)
        fill_in "access-code-entry", with: answer
        click_button "Continue"
        verify_login!
      end

      def download
        sleep 5
        rows = all(".details-container")
        rows.map { |row|
          {
            adapter: :ufb_direct,
            user: @user,
            id: row.find(".details-container__account-name").text,
            name: row.find(".details-container__account-name").text,
            amount: BigDecimal(
              row.find(".details-container__account-amount").text.match(/\$(.*)$/)[1].delete(",")
            )
          }
        }
      end

      private

      def verify_login!
        find ".details-container"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
