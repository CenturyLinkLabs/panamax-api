class JobsController < ApplicationController

  respond_to :json

  def index
    jobs = Job.with_templates(params[:type], params[:state])

    headers['Total-Count'] = jobs.size
    respond_with jobs
  end

  def show
    job = Job.find_by_key(params[:id])
    respond_with job
  end

  def create
    job = JobBuilder.create(job_params)
    job.start_job
    respond_with job
  end

  def destroy
    # use the dray client to destroy a job given the job id
  end

  def log
    job = Job.find_by_key(params[:id])
    log = job.log
    respond_with log
  end

  private

  def job_params
    params.permit(
      :template_id,
      override: [[environment: [[:variable, :value, :description]]]]
    )
  end
end
