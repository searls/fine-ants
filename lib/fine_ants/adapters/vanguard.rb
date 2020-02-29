require "bigdecimal"

module FineAnts
  module Adapters
    class Vanguard
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://personal.vanguard.com/us/hnwnesc/nesc/LoginPage"
        fill_in "LoginForm:USER", with: @user
        sleep 0.2
        fill_in "LoginForm:PASSWORD-blocked", with: @password
        click_button "LoginForm:submitInput"
        begin
          find_field "LoginForm:ANSWER"
          false
        rescue Capybara::ElementNotFound
          verify_login!
          true
        end
      end

      def two_factor_response(answer)
        fill_in "LoginForm:ANSWER", with: answer
        choose "LoginForm:DEVICE:0"
        click_button "LoginForm:ContinueInput"
        verify_login!
      end

      def download
        rows = find("[id='BalancesTabBoxId:balancesForm:balancesTable']").all("tr:not([tbodyid])")
        rows.map { |row|
          cells = row.all("td")
          {
            adapter: :vanguard,
            user: @user,
            id: cells.first.all("a").first[:href].match(/.*#(.*)$/)[1],
            name: cells.first.text,
            amount: BigDecimal(cells.last.text.match(/\$(.*)$/)[1].delete(","))
          }
        }.tap { click_link "Log off" }
      end

      private

      def verify_login!
        find_link "Log off"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
