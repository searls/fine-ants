require "bigdecimal"

module FineAnts
  module Adapters
    class Betterment
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://wwws.betterment.com/app/login"
        fill_in "web_authentication[email]", :with => @user
        fill_in "web_authentication[password]", :with => @password
        click_button "Log in"
        begin
          find_field "web_second_factor_authentication[verification_code]"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in "web_second_factor_authentication[verification_code]", :with => answer
        find(".web_second_factor_authentication_trust_device").click
        click_button "Verify"
        verify_login!
      end

      def download
        all(".ft-goalAccordionLabel").each { |accordion|
          accordion.click
          sleep 0.3
        }
        accounts = all ".ft-goalExpandedFooter .sc-ContentLayout:nth-child(1) .ft-accounts .ft-subAccountExpandedRow"
        accounts.map do |account|
          {
            :adapter => :betterment,
            :user => @user,
            :id => id_for(account),
            :name => name_for(account),
            :amount => total_for(account)
          }
        end.tap do
          find_logout_button.click
        end
      end

    private

      def verify_login!
        find_logout_button
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def find_logout_button
        find(".Navigation-logoutAction")
      end

      def id_for(account)
        account.find("a[data-track-name=\"AutoDepositIntended\"]")["data-track-broker-dealer-account-id"]
      end

      def name_for(account)
        "#{account.find(".ft-subAccountName").text} - #{account.ancestor(".sc-Card").find(".ft-goalName").text}"
      end

      def total_for(account)
        total_string = account.find(".ft-subAccountBalance").text
        BigDecimal.new(total_string.match(/\$(.*)$/)[1].gsub(/,/,''))
      end
    end
  end
end



