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
        fill_in "LoginForm:PASSWORD-blocked", :with => @password
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
        rows = find(".accountsList table").all("tr")
        rows.map do |row|
          cells = row.all("td")
          {
            :adapter => :vanguard,
            :user => @user,
            :id => cells.first.find("a")[:href].match(/.*#(.*)$/)[1],
            :name => cells.first.text,
            :amount => BigDecimal.new(cells.last.text.match(/\$(.*)$/)[1].gsub(/,/,''))
          }
        end.tap { click_link "Log off" }
      end

    private

      def verify_login!
        find ".lastLogon"
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end

