class Job < ActiveRecord::Base
  belongs_to :job_template
  has_many :job_steps, through: :job_template

  serialize :environment, Array
end
