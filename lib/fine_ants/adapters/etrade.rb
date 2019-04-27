require "bigdecimal"

module FineAnts
  module Adapters
    class Etrade
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://us.etrade.com/e/t/user/login"
        fill_in "USER", with: @user
        sleep 0.3
        fill_in "PASSWORD", with: @password
        click_button "Log on"
        verify_login!
      end

      def download
        all("section.account").map { |account|
          {
            adapter: :etrade,
            user: @user,
            id: account.find("#acctNum .number-reveal", visible: false).text(:all),
            name: account.find("a.account-id").text,
            amount: BigDecimal(account.find(".table-horizontal .text-right.secondary").text.gsub(/[\$,]/, "")),
          }
        }.tap do
          click_link "Log Off"
        end
      end

      private

      def verify_login!
        find_link "Log Off"
      rescue
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
