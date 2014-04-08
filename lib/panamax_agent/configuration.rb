require 'faraday'
require 'logger'

module PanamaxAgent
  module Configuration

    VALID_OPTIONS_KEYS = [
      :adapter,
      :registry_api_url,
      :registry_api_version,
      :etcd_api_url,
      :etcd_api_version,
      :open_timeout,
      :read_timeout,
      :ssl_options,
      :proxy,
      :logger
    ]

    DEFAULT_ADAPTER = Faraday.default_adapter
    DEFAULT_REGISTRY_API_URL = 'https://index.docker.io'
    DEFAULT_REGISTRY_API_VERSION = 'v1'
    DEFAULT_ETCD_API_URL = ENV['FLEETCTL_ENDPOINT']
    DEFAULT_ETCD_API_VERSION = 'v2'
    DEFAULT_OPEN_TIMEOUT = 2
    DEFAULT_READ_TIMEOUT = 5
    DEFAULT_SSL_OPTIONS = { verify: false }
    DEFAULT_LOGGER = ::Logger.new(STDOUT)

    attr_accessor(*VALID_OPTIONS_KEYS)

    def self.extended(base)
      base.reset
    end

    # Return a has of all the current config options
    def options
      VALID_OPTIONS_KEYS.inject({}) { |o,k| o.merge!(k => send(k)) }
    end

    def reset
      self.adapter = DEFAULT_ADAPTER
      self.registry_api_url = DEFAULT_REGISTRY_API_URL
      self.registry_api_version = DEFAULT_REGISTRY_API_VERSION
      self.etcd_api_url = DEFAULT_ETCD_API_URL
      self.etcd_api_version = DEFAULT_ETCD_API_VERSION
      self.open_timeout = DEFAULT_OPEN_TIMEOUT
      self.read_timeout = DEFAULT_READ_TIMEOUT
      self.ssl_options = DEFAULT_SSL_OPTIONS
      self.logger = DEFAULT_LOGGER
    end
  end
end
