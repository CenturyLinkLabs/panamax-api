class JobStep < ActiveRecord::Base
  belongs_to :job

  serialize :environment, Array
end
