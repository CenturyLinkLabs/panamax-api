class Job < ActiveRecord::Base
  include JobManagement

  belongs_to :job_template
  has_many :steps, -> { order(:position) }, class_name: 'JobStep'

  serialize :environment, Array

end
