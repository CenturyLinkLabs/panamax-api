class Service < ActiveRecord::Base
  belongs_to :app

  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Hash
  serialize :volumes, Array

  def unit_name
    "#{name}.service"
  end
end