class Job < ActiveRecord::Base
  include JobManagement

  belongs_to :job_template
  has_many :steps, -> { order(:order) },
           class_name: 'JobStep',
           dependent: :destroy

  serialize :environment, Array

  after_destroy :destroy_job

  def self.with_templates(type, state)
    type ||= JobTemplate.default_type
    jobs = self.joins(:job_template).where(job_templates: { type: type })
    jobs = jobs.select { |job| job.status == state } if state
    jobs
  end
end
