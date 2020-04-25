require "bigdecimal"

module FineAnts
  module Adapters
    class Target
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://rcam.target.com/default.aspx"

        fill_in "Login_UserName", with: @user
        fill_in "Login_Password", with: @password
        find("#Login_btnSignIn_btnSignIn").click

        verify_login!
      end

      def download
        balance = find("#AcctSummaryRCAM_AcctTbl_CrntBal").text
        available_balance = find("#AcctSummaryRCAM_AcctTbl_CredAvail").text
        next_due_date = find("#AcctSummaryRCAM_AcctTbl_PmtDueDt").text
        card_number = find("#AccountAcctNum").text.delete("For your REDcard ending in: ")

        [
          {
            adapter: :target,
            user: @user,
            id: "REDcard #{card_number}",
            name: "REDcard #{card_number}",
            type: :credit_card,
            amount: -1 * parse_currency(balance),
            available_amount: parse_currency(available_balance),
            next_due_date: parse_due_date(next_due_date)
          }
        ]
      end

      private

      def parse_currency(currency_string)
        BigDecimal(currency_string.match(/\$(.*)$/)[1].delete(","))
      end

      def parse_due_date(date_string)
        return nil if date_string == "-"
        date_string
      end

      def verify_login!
        find "span#DefaultPageTitle", text: "View Account Summary"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
