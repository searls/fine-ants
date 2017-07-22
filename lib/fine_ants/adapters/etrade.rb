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
        fill_in "User ID", :with => @user
        fill_in "Password", :with => @password
        click_button "Log on"
        verify_login!
      end

      def download
        all("section.account").map do |account|
          {
            :adapter => :etrade,
            :user => @user,
            :id => account.find("#acctNum .number-reveal", :visible => false).text(:all),
            :name => account.find("a.account-id").text,
            :amount => BigDecimal.new(account.find(".table-horizontal .text-right.secondary").text.gsub(/[\$,]/,''))
          }
        end.tap do
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




