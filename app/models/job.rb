class Job < ActiveRecord::Base
  include JobManagement

  belongs_to :job_template

  serialize :environment, Array

  delegate :steps, :steps=, to: :job_template
end
