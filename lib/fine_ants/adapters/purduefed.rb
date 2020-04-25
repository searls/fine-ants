require "bigdecimal"

module FineAnts
  module Adapters
    class Purduefed
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.purduefed.com"
        fill_in "USERNAME", with: @user
        click_button "Login"
        fill_in "M_content_PCDZ_MF3KFEF_ctl00_Password", with: @password
        click_button "Sign in"
      end

      def download
        deposit_table = find("span", text: /Deposit Accounts/)
          .find(:xpath, "../..")
          .find(".module_container")
        loan_table = find("span", text: /Loans/)
          .find(:xpath, "../..")
          .find(".module_container")
        deposit_transactions = process_table(deposit_table)
        loan_transactions = process_table(loan_table, type: :loan)

        deposit_transactions + loan_transactions
      end

      private

      def verify_login!
        find "Welcome, "
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError
      end

      def process_table(table, type: :deposit)
        transaction_rows(table) do |row|
          cells = row.all("td")
          amount = parse_currency(cells[1].text)
          amount = -amount if type == :loan
          name = cells[0].find("a").text

          {
            adapter: :purduefed,
            user: @user,
            id: name,
            name: name,
            type: type,
            amount: amount,
            available_amount: parse_currency(cells[2].text)
          }
        end
      end

      def transaction_rows(table)
        return [] if empty_table?(table)

        table.all("tr")[1..-2].map do |row|
          yield row
        end
      end

      def parse_currency(currency_string)
        BigDecimal(currency_string.match(/\$(.*)$/)[1].delete(","))
      end

      def empty_table?(table)
        table.all("tr")[1..-2].map(&:text).first == "No accounts to be displayed."
      end
    end
  end
end
