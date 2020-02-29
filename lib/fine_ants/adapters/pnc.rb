require "bigdecimal"

module FineAnts
  module Adapters
    class Pnc
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.onlinebanking.pnc.com/alservlet/SignonInitServlet"
        fill_in "userId", with: @user
        fill_in "password", with: @password
        click_button "Sign In"

        if all("input[value='Generate Code']").any?
          click_button "Generate Code"
          return false
        elsif all("input[name=answer]").any?
          return false
        else
          verify_login!
          return true
        end
      end

      def two_factor_response(text_or_answer)
        if all("input[name=answer]").any? # Security Q
          fill_in "answer", with: text_or_answer
        else # Text message challenge
          fill_in "otpNumber", with: text_or_answer
        end
        click_button "Continue"
        verify_login!
      end

      def download
        rows = all("#depositAccountsWrapper tr.depAccount")
        rows.map { |row|
          cells = row.all("td")
          {
            adapter: :pnc,
            user: @user,
            id: cells[2].text, # TODO - this won't be unique, only gives last 4 :-/
            name: cells[0].text,
            amount: BigDecimal(cells[3].text.match(/\$(.*)$/)[1].delete(",")),
          }
        }.tap { click_link "Sign Off" }
      end

      private

      def verify_login!
        find ".lastSignOn"
      rescue
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
