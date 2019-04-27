require "fine_ants/version"
require "fine_ants/capybara_setup"
require "fine_ants/adapters"
require "fine_ants/runner"
require "fine_ants/login_failed_error"

module FineAnts
  def self.download(adapter_name, credentials)
    adapter = if adapter_name.instance_of?(Class)
      adapter_name
    else
      Adapters.look_up(adapter_name)
    end
    Runner.new(adapter.new(credentials), credentials).download
  end
end
