require "bigdecimal"

module FineAnts
  module Adapters
    class Wealthfront
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.wealthfront.com/login"
        fill_in "login-username", with: @user
        fill_in "login-password", with: @password
        click_button "Log in"

        begin
          find_field "mfa-auth-code"
          false
        rescue Capybara::ElementNotFound
          verify_login!
        end
      end

      def two_factor_response(answer)
        fill_in "mfa-auth-code", with: answer
        check
        click_button "Log in"
      end

      def download
        rows = find_all('[href*="/accounts"]')
        rows.map { |row|
          cells = row.find_all('[data-toolkit-component="Text"]')

          {
            adapter: :wealthfront,
            user: @user,
            id: row["data-testid"].sub("dashboard-account-list-account-item-", ""),
            name: cells.first.text,
            amount: BigDecimal(cells[1].text.match(/\$(.*)$/)[1].delete(","))
          }
        }.tap { log_off! }
      end

      private

      def verify_login!
        has_text?("Overview")
      end

      def log_off!
        find('[href="/profile"]').click
        click_link "Log out"
      end
    end
  end
end
