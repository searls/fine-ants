require "bigdecimal"

module FineAnts
  module Adapters
    class Strs
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.nrsstrsoh.org/iApp/tcm/nrsstrsoh/index.jsp"
        fill_in "Username", with: @user
        fill_in "Password (Case sensitive)", with: @password
        click_button "Log In"
        begin
          find_field "contactPoint"
          false
        rescue Capybara::ElementNotFound
          verify_login!
          true
        end
      end

      def two_factor_response(answer)
        fill_in "confirmationCode", with: answer
        find_field("continue").click
        begin
          find "#rememberTrue"
          choose "#rememberTrue"
          find_field("#search").click
        rescue Capybara::ElementNotFound
        end
        verify_login!
      end

      def download
        [
          {
            adapter: :strs,
            user: @user,
            id: find(".plan-info-plan .disabled-phone-link").text,
            name: find(".plan-info-plan").text,
            amount: BigDecimal(find(".dash-health-alt__total_number").text.gsub(/[\$,\s]/, ""))
          }
        ].tap do
          click_link "Log Out"
        end
      end

      private

      def verify_login!
        find(".dash-health-alt__current_total_balance")
      rescue
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
