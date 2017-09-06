module FineAnts
  class Runner
    def initialize(adapter, credentials)
      @adapter = adapter
      @credentials = credentials
    end

    def download
      login!
      @adapter.download
    end

  private

    def login!
      puts "Attempting to login to #{@adapter.class.name} as '#{@credentials[:user]}'"
      login_complete = @adapter.login
      if !login_complete && @adapter.respond_to?(:two_factor_response)
        puts <<-TEXT.gsub(/^\s+/,'')
          #{@adapter.class.name} is requiring two-factor auth.
          Check your SMS/Email/TOTP and type it here:
        TEXT
        response = STDIN.gets.chomp
        @adapter.two_factor_response(response)
      end
    end

  end
end

