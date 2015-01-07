class JobTemplate < ActiveRecord::Base
  has_many :job_steps, -> { order(:order) }

  serialize :environment, Array

end
