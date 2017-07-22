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
        accounts = all(".SummaryTable-card")
        accounts.map do |account|
          {
            :adapter => :betterment,
            :user => @user,
            :id => id_for(account),
            :name => name_for(account),
            :amount => total_for(account)
          }
        end.tap do
          find('.sc-Nav-panelTrigger').click
          find('.sc-Nav-panelTrigger').click
          find('.sc-Nav-panelTrigger .SecondaryNavLogoutAction button', visible: false).click
        end
      end

    private

      def verify_login!
        find ".Dashboard-summaryCards"
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def id_for(account)
        link = account.find(".SummaryTable-donutContainer a")
        link[:href].match(/\/app\/goals\/(\d+)\//)[1]
      end

      def name_for(account)
        "#{account.find(".SummaryTable-accountName .SummaryTable-label").text} - #{account.find(".SummaryTable-accountName .u-secondaryHeading").text}"
      end

      def total_for(account)
        total_string = account.find(".SummaryTable-rightAlignedText .u-secondaryHeading").text
        BigDecimal.new(total_string.match(/\$(.*)$/)[1].gsub(/,/,''))
      end
    end
  end
end



