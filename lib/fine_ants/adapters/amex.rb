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
        within "#ssoform" do
          fill_in "User ID", :with => @user
          fill_in "Password", :with => @password
          click_link "Log In"
        end
        verify_login!
      end

      def download
        visit "https://global.americanexpress.com/accounts"
        all(".card-block > div").map do |account|
          name = account.find('.heading-3').text
          owed = account.all("table td").size == 3
          {
            :adapter => :amex,
            :user => @user,
            :id => name,
            :name => name,
            :amount => -1 * BigDecimal.new(if owed
                account.find("table td:nth-child(2) span").text.gsub(/[\$,]/,'')
              else
                "0"
              end)
          }
        end.tap do
          page.driver.go_back
          click_button "Log Out"
        end
      end

    private

      def verify_login!
        find_button "Log Out"
      rescue
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end





