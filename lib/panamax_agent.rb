require 'panamax_agent/configuration'
require 'panamax_agent/journal/client'
require 'panamax_agent/mailchimp/client'
require 'panamax_agent/panamax/client'
require 'panamax_agent/registry/client'

module PanamaxAgent
  extend Configuration

  def self.registry_client(options={})
    PanamaxAgent::Registry::Client.new(options)
  end

  def self.journal_client(options={})
    PanamaxAgent::Journal::Client.new(options)
  end

  def self.panamax_client(options={})
    PanamaxAgent::Panamax::Client.new(options)
  end

  def self.mailchimp_client(options={})
    PanamaxAgent::Mailchimp::Client.new(options)
  end

  def self.configure
    yield self
    true
  end
end
