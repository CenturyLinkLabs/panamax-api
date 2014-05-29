require 'panamax_agent/client'
require 'panamax_agent/panamax/client/components'

module PanamaxAgent
  module Panamax
    class Client < PanamaxAgent::Client

      attr_reader :registry_client

      def initialize(options={})
        super
        @registry_client = PanamaxAgent::Registry::Client.new(
          registry_api_url: pmx_registry_api_url,
          registry_api_version: pmx_registry_api_version)
      end

      include PanamaxAgent::Panamax::Client::Components

    end
  end
end
