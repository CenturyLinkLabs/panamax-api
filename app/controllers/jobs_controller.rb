class JobsController < ApplicationController

  respond_to :json

  def index
    type = params[:type] || JobTemplate.default_type
    state = params[:state]

    jobs = Job.joins(:job_template).where(job_templates: { type: type })
    jobs.select { |job| job.status == state } if state

    headers['Total-Count'] = jobs.count
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
