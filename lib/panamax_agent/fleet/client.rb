require 'json'
require 'panamax_agent/client'
require 'panamax_agent/fleet/client/job'
require 'panamax_agent/fleet/client/state'
require 'panamax_agent/fleet/client/unit'


module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client

      FLEET_PATH = '/keys/_coreos.com/fleet'

      def initialize(options={})
        super
        @base_path = etcd_api_version + FLEET_PATH
      end

      include PanamaxAgent::Fleet::Connection

      include PanamaxAgent::Fleet::Client::Job
      include PanamaxAgent::Fleet::Client::State
      include PanamaxAgent::Fleet::Client::Unit

      def submit(service_def)
        create_unit(service_def.sha1, service_def.unit_def)
        create_job(service_def.name, service_def.job_def)
      end

      def start(service_name)
        update_job_target_state(service_name, :launched)
      end

      def stop(service_name)
        update_job_target_state(service_name, :loaded)
      end

      def unload(service_name)
        update_job_target_state(service_name, :inactive)
      end

      def destroy(service_name)
        delete_job(service_name)
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
