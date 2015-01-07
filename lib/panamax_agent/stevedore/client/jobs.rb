module PanamaxAgent
  module Stevedore
    class Client < PanamaxAgent::Client
      module Jobs

        JOBS_RESOURCE = 'jobs'

        def create_job(job)
          post(jobs_path, job.to_json)
        end

        def list_jobs
          get(jobs_path)
        end

        def get_job(job_id)
          get(jobs_path(job_id))
        end

        def get_job_log(job_id)
          get(jobs_path(job_id, 'log'))
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
