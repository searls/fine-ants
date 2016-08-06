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
        fill_in "LoginForm:USER", :with => @user
        fill_in "LoginForm:PASSWORD", :with => @password
        click_button "LoginForm:submitInput"
        begin
          find_field "LoginForm:ANSWER"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in "LoginForm:ANSWER", :with => answer
        choose "LoginForm:DEVICE:0"
        click_button "LoginForm:ContinueInput"
        verify_login!
      end

      def download
        rows = find(:id, "BalancesTabBoxId:balancesForm:balancesTable").all("tr")
        rows[0..-3].map do |row|
          cells = row.all("td")
          {
            :adapter => :vanguard,
            :user => @user,
            :id => cells[0].find("a")[:href].match(/.*#(.*)$/)[1],
            :name => cells[0].find("a").text,
            :amount => BigDecimal.new(cells[1].text.match(/\$(.*)$/)[1].gsub(/,/,''))
          }
        end
      end

    private

      def verify_login!
        find "#comp-lastLogon"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end

