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
        fill_in "userId", :with => @user
        click_button "Sign On"

        if all("input[name=answer").any?
          return false
        else
          try_password!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in "answer", :with => answer
        click_button "Continue"
        try_password!
      end

      def download
        rows = all("tr.depAccount")
        rows[0..-3].map do |row|
          cells = row.all("td")
          {
            :adapter => :pnc,
            :user => @user,
            :id => cells[2].text, # TODO - this won't be unique, only gives last 4 :-/
            :name => cells[0].text,
            :amount => BigDecimal.new(cells[3].text.match(/\$(.*)$/)[1].gsub(/,/,''))
          }
        end.tap { click_link "Sign Off" }
      end

    private

      def try_password!
        fill_in "password", :with => @password
        click_button "Sign On"
        find ".lastSignOn"
      rescue
        raise FineAnts::LoginFailedError.new
      end

    end
  end
end


