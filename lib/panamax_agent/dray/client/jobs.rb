module PanamaxAgent
  module Dray
    class Client < PanamaxAgent::Client
      module Jobs

        JOBS_RESOURCE = 'jobs'
        def create_job(job_attrs)
          post(jobs_path, job_attrs)
        end

        def list_jobs
          get(jobs_path)
        end

        def get_job(job_id)
          get(jobs_path(job_id))
        end

        def get_job_log(job_id, options={})
          get(jobs_path(job_id, 'log'), options)
        end

        def delete_job(job_id)
          delete(jobs_path(job_id))
        end

        private

        def jobs_path(*parts)
          resource_path(JOBS_RESOURCE, *parts)
        end

      end
    end
  end
end
