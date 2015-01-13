class JobsController < ApplicationController

  respond_to :json

  def index
    type = params[:type] || 'ClusterJobTemplate'
    state = params[:state]

    jobs = Job.joins(:job_template).where(job_templates: { type: type })
    if state
      jobs = jobs.select { |job| job.status == state }
    end

    headers['Total-Count'] = jobs.count
    respond_with jobs
  end

  def show
    # fetches job details for the given the job id
    job = Job.find_by_key(params[:id])
    respond_with job
  end

  def create
    # creates a job from the template form data
    job = JobBuilder.create(job_params)
    job.start_job
    respond_with job
  end

  def destroy
    # uses the stevedore client to destroy a job given the job id
  end

  def log
    # uses the stevedore client to retrieve job log given the job id
  end

  private

  def job_params
    params.permit(
      :template_id,
      override: [[environment: [[:variable, :value, :description]]]]
    )
  end
end
