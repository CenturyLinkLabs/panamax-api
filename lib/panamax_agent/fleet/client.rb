require 'json'
require 'panamax_agent/client'
require 'panamax_agent/error'
require 'panamax_agent/fleet/client/job'
require 'panamax_agent/fleet/client/state'
require 'panamax_agent/fleet/client/unit'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client

      FLEET_PATH = '/keys/_coreos.com/fleet'
      MAX_RETRIES = 10
      SLEEP_TIME = (1.0 / 10.0)

      def initialize(options={})
        super
        @base_path = etcd_api_version + FLEET_PATH
      end

      include PanamaxAgent::Fleet::Connection

      include PanamaxAgent::Fleet::Client::Job
      include PanamaxAgent::Fleet::Client::State
      include PanamaxAgent::Fleet::Client::Unit

      def load(service_def)
        begin
          create_unit(service_def.sha1, service_def.unit_def)
        rescue PanamaxAgent::PreconditionFailed
        end

        begin
          create_job(service_def.name, service_def.job_def)
        rescue PanamaxAgent::PreconditionFailed
        end

        update_job_target_state(service_def.name, :loaded)
        wait_for_load_state(service_def.name, 'loaded')
      end

      def start(service_name)
        update_job_target_state(service_name, :launched)
      end

      def stop(service_name)
        update_job_target_state(service_name, :loaded)
        wait_for_load_state(service_name, 'loaded')
      end

      def unload(service_name)
        update_job_target_state(service_name, :inactive)
        wait_for_load_state(service_name, 'not-found')
      end

      def destroy(service_name)
        delete_job(service_name)
        wait_for_load_state(service_name, :no_state)
      end

      def states(service_name)
        fleet_state = get_state(service_name)
        service_states = JSON.parse(fleet_state['node']['value'])
        service_states.each_with_object({}) do |(k, v), hash|
          hash[k.underscore.to_sym] = v
        end
      end

      protected

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@base_path).join('/')
      end

      def wait_for_load_state(service_name, target_state='loaded')
        result = MAX_RETRIES.times do
          begin
            break target_state if states(service_name)[:load_state] == target_state
          rescue PanamaxAgent::NotFound
            # :no_state is a special case of target state that indicates we
            # expect the state to not be found at all (useful when waiting for
            # a delete job call)
            break target_state if target_state == :no_state
          end

          sleep(SLEEP_TIME)
        end

        if result == target_state
          true
        else
          fail PanamaxAgent::Error,
            "Job state '#{target_state}' could not be achieved"
        end
      end

    end
  end
end
