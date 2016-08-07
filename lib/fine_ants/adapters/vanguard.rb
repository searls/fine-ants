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

      # TODO: Rename this to be more explicit about what is being downloaded?
      def download
        rows = find(:id, "BalancesTabBoxId:balancesForm:balancesTable").all("tr")
        rows[0..-3].map do |row|
          cells = row.all("td")
          # TODO: Extract this into a class?
          {
            :adapter => :vanguard,
            :user => @user,
            :id => cells[0].find("a")[:href].match(/.*#(.*)$/)[1],
            :name => cells[0].find("a").text,
            :amount => BigDecimal.new(cells[1].text.match(/\$(.*)$/)[1].gsub(/,/,''))
          }
        end
      end

      def download_transactions
        # Go to the "Download account information" page
        visit "https://personal.vanguard.com/us/OfxWelcome"

        # Select the download format: "Quicken: All funds to a single account"
        find(:id, 'OfxDownloadForm:downloadOption_main').click
        find(:id, 'menu-OfxDownloadForm:downloadOption').find('td', :value => 'SingleQuicken').click

        # Select date range: 1 month
        # TODO: Allow a date range to be passed in, and find the smallest option
        # which provides the data requested.
        # An app which uses this gem would probably store the last time a successful
        # request was made, and request all activity since that time.
        # Since we are currently only handling the default date range, we do not need
        # to click on anything, so the next line is commented out.
        # find(:id, 'OfxDownloadForm:ofxDateFilterSelectOneMenu_main').click

        # Select the account(s) to download
        # By default, download all accounts
        find(:id, 'OfxDownloadForm:accountsTable').find(id: 'OfxDownloadForm:selectOrDeselect').click

        # Click on the download button
        find(:id, 'OfxDownloadForm:downloadButtonInput').click

        puts page.response_headers

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

