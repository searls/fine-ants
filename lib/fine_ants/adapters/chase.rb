require "bigdecimal"

module FineAnts
  module Adapters
    class Chase
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.chase.com"
        within_frame(find("#logonbox")) do
          fill_in "Username", :with => @user
          fill_in "Password", :with => @password
          # I'm not happy with this. Chase's site seems to blank out the
          # username and password fields if you hit "Sign in" immediately after
          # the dialog appears. We're sleeping to sidestep this behavior.
          sleep 0.1
          click_on "Sign in"
        end
        verify_login!
      end

      def logout
        click_button "Sign out"
      end

      def download
        # Select credit card
        find("h3", text: "CREDIT CARDS")
          .find(:xpath, "../..")
          .find("section")
          .first("div")
          .click

        credit_card_table = find("table.dl-box")

        balance = credit_card_table.find("#accountCurrentBalance").text
        available_balance = credit_card_table.find("#accountAvailableCreditBalance").text
        next_due_date = credit_card_table.find("#nextPaymentDueDate").text

        accounts = [
          {
            :adapter => :chase,
            :user => @user,
            :id => find(".ACTNAME").text,
            :name => find(".ACTNAME").text,
            :type => :credit_card,
            :amount => -1 * parse_currency(balance),
            :available_amount => parse_currency(available_balance),
            :next_due_date => parse_due_date(next_due_date)
          }
        ]

        logout
        accounts
      end

      private

      def parse_currency(currency_string)
        BigDecimal.new(currency_string.match(/\$(.*)$/)[1].delete(","))
      end

      def parse_due_date(due_date_string)
        Date.strptime(due_date_string, "%b %d, %Y")
      end

      def verify_login!
        find '[data-attr="LOGON_DETAILS.lastLogonDetailsLabel"]'
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end

