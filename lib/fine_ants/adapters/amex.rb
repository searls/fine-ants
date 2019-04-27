require "bigdecimal"

module FineAnts
  module Adapters
    class Amex
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.americanexpress.com"
        form_css = find("form")[:id] == "ssoform" ? "#ssoform" : ".eliloMain"
        within form_css do
          fill_in "User ID", with: @user
          fill_in "Password", with: @password
          click_thing "Log In"
        end
        verify_login!
      end

      def download
        visit "https://global.americanexpress.com/accounts"
        find(".card-block")
        all(".card-block > div").map do |account|
          name = account.find(".card > .pad > .heading-3").text
          owed = account.text.include?("Total Balance")
          {
            adapter: :amex,
            user: @user,
            id: name,
            name: name,
            amount: -1 * BigDecimal(if owed
                           account.all("table td:nth-child(2) span").first.text.gsub(/[\$,]/, "")
                         else
                           "0"
                                    end),
          }
        end
      end

      private

      def verify_login!
        page.has_text? "Log Out"
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def click_thing(locator)
        click_link locator
      rescue
        click_button locator
      end
    end
  end
end
