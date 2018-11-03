require "bigdecimal"

module FineAnts
  module Adapters
    class Vanguard
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://investor.vanguard.com/my-account/log-on-ecx"
        fill_in "User name", :with => @user
        fill_in "Password", :with => @password
        click_button "Log On"
        begin
          find_field "code"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        binding.pry
        fill_in "code", :with => answer
        choose "YES"
        click_button "Continue"
        verify_login!
      end

      def download
        rows = find(".accountsList table").all("tr")
        rows.map do |row|
          cells = row.all("td")
          {
            :adapter => :vanguard,
            :user => @user,
            :id => cells.first.all("a").first[:href].match(/.*#(.*)$/)[1],
            :name => cells.first.text,
            :amount => BigDecimal.new(cells.last.text.match(/\$(.*)$/)[1].gsub(/,/,''))
          }
        end.tap { click_link "Log off" }
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

