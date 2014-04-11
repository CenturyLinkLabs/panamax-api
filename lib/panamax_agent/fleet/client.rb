require 'json'
require 'panamax_agent/client'
require 'panamax_agent/fleet/client/payload'
require 'panamax_agent/fleet/client/job'
require 'panamax_agent/fleet/client/state'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client

      FLEET_PATH = '/keys/_coreos.com/fleet'

      def initialize(options={})
        super
        self.url = self.etcd_api_url
        @base_path = etcd_api_version + FLEET_PATH
      end

      include PanamaxAgent::Fleet::Client::Payload
      include PanamaxAgent::Fleet::Client::Job
      include PanamaxAgent::Fleet::Client::State

      def submit(service_def)
        create_payload(service_def.name, service_def.to_hash)
      end

      def start(service_name)
        payload_json = get_payload(service_name)
        payload = json_to_hash(payload_json['node']['value'])

        # Wrap payload in a job
        job = {
          "Name" => service_name,
          "JobRequirements" => {},
          "Payload" => payload,
          "State" => nil
        }

        create_job(service_name, job)
      end

      protected

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@base_path).join('/')
      end

      def json_to_hash(json)
        begin
          JSON.parse(json)
        rescue Exception
          {}
        end
      end

    end
  end
end
