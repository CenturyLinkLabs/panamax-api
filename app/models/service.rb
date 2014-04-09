class Service < ActiveRecord::Base
  belongs_to :app

  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Array
  serialize :volumes, Array

end