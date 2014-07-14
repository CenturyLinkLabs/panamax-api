class Service < ActiveRecord::Base
  include DockerRunnable
  include ServiceJournal
  include Classifiable

  self.inheritance_column = :_type_disabled

  belongs_to :app
  has_many :service_categories
  has_many :categories,
    class_name: 'ServiceCategory',
    foreign_key: 'service_id',
    dependent: :destroy
  has_many :links,
    class_name: 'ServiceLink',
    foreign_key: 'linked_from_service_id',
    dependent: :destroy

  # Only here for the dependent destroy. Want to remove any service link joins that may point
  # to this model as the 'linked_to_service'
  has_many :linked_from_links,
    class_name: 'ServiceLink',
    foreign_key: 'linked_to_service_id',
    dependent: :destroy

  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Array
  serialize :command, Array
  serialize :volumes, Array

  before_save :resolve_name_conflicts
  after_destroy :shutdown

  validates_presence_of :name
  validates :ports, has_container_ports: true, has_unique_ports: true
  validates :volumes, has_container_paths: true

  attr_writer :manager

  def unit_name
    "#{name}.service"
  end

  def service_state
    manager.get_state
  end

  def submit
    manager.load
  end

  def start
    manager.start
  end

  def shutdown
    manager.destroy rescue nil
  end

  def restart
    self.shutdown
    self.submit
    self.start
  end

  # Works just like ActiveRecord::Persistence#update but will also update relations
  def update_with_relationships(attributes)
    attributes[:links] ||= []
    attributes[:links].map! do |link|
      self.links.find_or_initialize_by(
        linked_to_service_id: link[:service_id],
        alias: link[:alias]
      )
    end

    attributes[:categories] ||= []
    attributes[:categories].map! do |category|
      self.categories.find_or_initialize_by(
        app_category_id: category[:id],
        position: category[:position]
      )
    end

    attributes[:volumes] ||= []
    attributes[:volumes].map! { |vol| vol.to_hash }

    attributes[:ports] ||= []
    attributes[:ports].map! { |port| port.to_hash }

    attributes[:environment] ||= []
    attributes[:environment].map! { |var| var.to_hash }

    self.update(attributes)
  end

  private

  def manager
    @manager ||= ServiceManager.new(self)
  end

  def sanitize_name(bad_name)
    # Allow only chars - A-z, 0-9, ., -, _ in names
    bad_name.gsub(/[^0-9A-z.-]|[\^]|[\`]|[\[]|[\]]/, '_')
  end

  def increment_name(name)
    if self.name_changed? || !persisted?
      count = Service.where('name LIKE ?', "#{name}%").count
      name = (count > 0) ? "#{name}_#{count}" : name
    end
    name
  end

  def resolve_name_conflicts
    sanitized_name = sanitize_name(name)
    self.name = increment_name(sanitized_name)
  end
end
