class JobTemplate < ActiveRecord::Base
  has_many :job_steps, -> { order(:order) }

  serialize :environment, Array

  scope :cluster_job_templates, -> { where(type: 'ClusterJobTemplate') }
end
