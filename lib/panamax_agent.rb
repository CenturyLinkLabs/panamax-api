require 'panamax_agent/configuration'
require 'panamax_agent/registry/client'

module PanamaxAgent
  extend Configuration

  def self.registry_client(options={})
    PanamaxAgent::Registry::Client.new(options)
  end

  def self.configure
    yield self
    true
  end
end
