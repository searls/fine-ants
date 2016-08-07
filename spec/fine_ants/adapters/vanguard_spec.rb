require "spec_helper"

def required_value(adapter_name, env_key)
  # TODO: Add validation? Add a regex as an optional argument?
  return ENV[env_key] unless ENV[env_key].nil?
  puts <<-TEXT.gsub(/^\s+/,'')
    To run the specs for the #{adapter_name} adapter, a valid value is required
    for #{env_key}.
    It can be set in .env or as an ENV variable on the command line.
    Or you may enter the value for #{env_key} here:
  TEXT
  gets.chomp
end

RSpec.describe FineAnts::Adapters::Vanguard do
  let(:adapter) { FineAnts::Adapters::Vanguard.new(credentials) }

  context "invalid credentials" do
    let(:credentials) { Hash[user: 'foo', password: 'bar'] }

    describe "#login" do
      it "raises a FineAnts::LoginFailedError exception" do
        expect{adapter.login}.to raise_exception(FineAnts::LoginFailedError)
      end
    end
  end

  context "valid credentials" do
    let(:valid_user) { required_value('Vanguard', 'VANGUARD_USER') }
    let(:valid_password) { required_value('Vanguard', 'VANGUARD_PASSWORD') }

    let(:credentials) { Hash[user: valid_user, password: valid_password] }

    # NOTE: We really want to test login with two_factor_response
    # This suggests that the IO logic in FineAnts::Runner#login! should be moved to the adapter
    describe "#login" do
      it "returns true" do
        runner = FineAnts::Runner.new(adapter, credentials)
        runner.send(:login!)
        # If the previous line does not raise an exception, then we successfully logged in.
        # So there is no assertion needed for this spec.
      end
    end

    describe "#download" do
      it "does what it is supposed to" do
        skip
      end
    end
  end
end
