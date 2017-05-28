require "spec_helper"

RSpec.describe FineAnts::Adapters::Vanguard do
  let(:adapter) { FineAnts::Adapters::Vanguard.new(credentials) }

  context "valid credentials" do
    let(:valid_user) { required_value('Vanguard', 'VANGUARD_USER') }
    let(:valid_password) { required_value('Vanguard', 'VANGUARD_PASSWORD') }

    let(:credentials) { Hash[user: valid_user, password: valid_password] }

    describe "#download_transactions" do
      before do
        runner = FineAnts::Runner.new(adapter, credentials)
        runner.send(:login!)
      end

      it "does something with a downloaded file..." do
        file = adapter.download_transactions
        # TODO: Add expectation on file type or contents. Maybe high-level format?
      end
    end
  end
end
