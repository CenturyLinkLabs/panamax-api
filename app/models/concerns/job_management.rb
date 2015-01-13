module JobManagement
  extend ActiveSupport::Concern

  def status
    job_state['status']
  end

  def completed_steps
    job_state['stepsCompleted'].try(:to_i)
  end

  def start_job
    job_run = stevedore_client.create_job(job_attrs)
    update(key: job_run['id'])
  end

  def destroy_job
    destroy if stevedore_client.delete_job(self.key)
  end

  private

  def job_state
    @job_state ||= get_state
  end

  def get_state
    stevedore_client.get_job(self.key)
  rescue
    {}
  end

  def stevedore_client
    PanamaxAgent.stevedore_client
  end

  def job_attrs
    JobLiteSerializer.new(self).as_json
  end

end
