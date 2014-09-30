class Image < ActiveRecord::Base
  include Classifiable

  self.inheritance_column = :_type_disabled

  serialize :categories, Array
  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Array
  serialize :volumes, Array
  serialize :volumes_from, Array

  belongs_to :template

  validates_presence_of :name
  validates_presence_of :source
  validates :ports, has_container_ports: true, has_unique_ports: true
  validates :links, has_link_alias: true, service_link_exists: true
  validates :volumes, has_container_paths: true
  validates :volumes_from, shared_volume_service_exists: true
end
