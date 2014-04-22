require 'panamax_agent/request'

module PanamaxAgent
  class Client

    include PanamaxAgent::Request

    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)

    def initialize(options={})
      options = PanamaxAgent.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    protected

    def resource_path(resource, *parts)
      parts.unshift(resource).join('/')
    end
  end
end
