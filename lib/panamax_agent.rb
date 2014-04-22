require 'panamax_agent/configuration'

module PanamaxAgent
  extend Configuration

  def self.registry_client(options={})
    PanamaxAgent::Registry::Client.new(options)
  end

  def self.fleet_client(options={})
    PanamaxAgent::Fleet::Client.new(options)
  end

  def self.journal_client(options={})
    PanamaxAgent::Journal::Client.new(options)
  end

  def self.configure
    yield self
    true
  end
end
