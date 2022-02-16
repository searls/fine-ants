require "bigdecimal"

module FineAnts
  module Adapters
    class Schwab
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://client.schwab.com/Login/SignOn/CustomerCenterLogin.aspx"
        within_frame 'lmsSecondaryLogin' do
          fill_in "loginIdInput", with: @user
          fill_in "passwordInput", with: @password
          select "Accounts Summary", from: "landingPageOptions"
          click_button "btnLogin"
        end

        begin
          find("#otp_sms").click
          false
        rescue Capybara::ElementNotFound
          verify_login!
          true
        end
      end

      def two_factor_response(answer)
        fill_in "securityCode", with: answer
        click_button "continueButton"
        verify_login!
      end

      def download
        rows = all(".account-row")
        rows.map { |row|
          {
            adapter: :schwab,
            user: @user,
            id: row.all(".account.number").first.text.strip,
            name: row.all(".nickName-wrapper").first.text.strip,
            amount: BigDecimal(row.all(".balance-container-cs .values-wrapper").first.text.match(/\$(.*)$/)[1].delete(","))
          }
        }.tap { click_button "Log Out" }
      end

      private

      def verify_login!
        find_button "Log Out"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
