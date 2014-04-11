require 'panamax_agent/client'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client
      module Job

        JOB_RESOURCE = 'job'

        def list_jobs
          opts = { consistent: true, recursive: true, sorted: true }
          get(job_path, opts)
        end

        def get_job(service_name)
          opts = { consistent: true, recursive: true, sorted: false }
          get(job_path(service_name, :object), opts)
        end

        def create_job(service_name, job)
          opts = {
            querystring: { 'prevExist' => false },
            body: { value: job.to_json }
          }
          put(job_path(service_name, :object),
              opts,
              headers={},
              request_type=:url_encoded)
        end

        def delete_job(service_name)
          opts = { dir: false, recursive: true }
          delete(job_path(service_name), opts)
        end

        private

        def job_path(*parts)
          resource_path(JOB_RESOURCE, *parts)
        end

      end
    end
  end
end
