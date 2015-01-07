require 'faraday'
require 'logger'

module PanamaxAgent
  module Configuration

    VALID_OPTIONS_KEYS = [
      :adapter,
      :registry_api_url,
      :registry_api_version,
      :journal_api_url,
      :pmx_registry_api_url,
      :pmx_registry_api_version,
      :stevedore_api_url,
      :mailchimp_api_url,
      :mailchimp_user,
      :mailchimp_id,
      :mailchimp_group_id,
      :open_timeout,
      :read_timeout,
      :ssl_options,
      :proxy,
      :logger
    ]

    DEFAULT_ADAPTER = Faraday.default_adapter
    DEFAULT_REGISTRY_API_URL = 'https://index.docker.io'
    DEFAULT_REGISTRY_API_VERSION = 'v1'
    DEFAULT_JOURNAL_API_URL = ENV['JOURNAL_ENDPOINT']
    DEFAULT_PMX_REGISTRY_API_URL = 'http://74.201.240.198:5000'
    DEFAULT_PMX_REGISTRY_API_VERSION = 'v1'
    DEFAULT_STEVEDORE_API_URL = ENV['STEVEDORE_ENDPOINT']
    DEFAULT_MAILCHIMP_API_URL = 'http://centurylinklabs.us3.list-manage.com'
    DEFAULT_MAILCHIMP_USER = '021d5aea02a4ed5dec0c1c96c'
    DEFAULT_MAILCHIMP_ID = '7bb216c547'
    DEFAULT_MAILCHIMP_GROUP_ID = 'group[9397][2]'
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
      VALID_OPTIONS_KEYS.each_with_object({}) { |k, o| o[k] = send(k) }
    end

    def reset
      self.adapter = DEFAULT_ADAPTER
      self.registry_api_url = DEFAULT_REGISTRY_API_URL
      self.registry_api_version = DEFAULT_REGISTRY_API_VERSION
      self.journal_api_url = DEFAULT_JOURNAL_API_URL
      self.pmx_registry_api_url = DEFAULT_PMX_REGISTRY_API_URL
      self.pmx_registry_api_version = DEFAULT_PMX_REGISTRY_API_VERSION
      self.stevedore_api_url = DEFAULT_STEVEDORE_API_URL
      self.mailchimp_api_url = DEFAULT_MAILCHIMP_API_URL
      self.mailchimp_user = DEFAULT_MAILCHIMP_USER
      self.mailchimp_id = DEFAULT_MAILCHIMP_ID
      self.mailchimp_group_id = DEFAULT_MAILCHIMP_GROUP_ID
      self.open_timeout = DEFAULT_OPEN_TIMEOUT
      self.read_timeout = DEFAULT_READ_TIMEOUT
      self.ssl_options = DEFAULT_SSL_OPTIONS
      self.logger = DEFAULT_LOGGER
    end
  end
end
