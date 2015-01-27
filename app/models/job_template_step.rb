class JobTemplateStep < ActiveRecord::Base
  belongs_to :job_template

  serialize :environment, Array
end
