class Service < ActiveRecord::Base
  include DockerRunnable
  include ServiceJournal

  belongs_to :app
  has_many :service_categories
  has_many :categories,
    class_name: 'ServiceCategory',
    foreign_key: 'service_id',
    dependent: :destroy
  has_many :links, class_name: 'ServiceLink', foreign_key: 'linked_from_service_id',
    dependent: :destroy

  # Only here for the dependent destroy. Want to remove any service link joins that may point
  # to this model as the 'linked_to_service'
  has_many :linked_from_links, class_name: 'ServiceLink', foreign_key: 'linked_to_service_id',
    dependent: :destroy

  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Hash
  serialize :volumes, Array

  before_save   :resolve_name_conflicts
  after_destroy :shutdown

  validates_presence_of :name

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

  def copy_categories_from_image(image, app_categories)
    image.categories.each do |image_cat|
      app_category = app_categories.detect { |app_cat| app_cat.name == image_cat.name }
      self.categories << ServiceCategory.new(
        app_category_id: app_category.id,
        position: image_cat[:position])
    end
  end

  def copy_links_from_image(image, services)
    image.links.each do |link|
      linked_to_service = services.find { |service| service.name == link[:service] }
      self.links << ServiceLink.new(linked_to_service: linked_to_service, alias: link[:alias])
    end
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

    attributes[:ports] ||= []
    attributes[:environment] ||= {}

    self.update(attributes)
  end

  def self.new_from_image(image)
    self.new(
      name: image.name,
      description: image.description,
      from: "#{image.repository}:#{image.tag}",
      ports: image.ports,
      expose: image.expose,
      environment: image.environment,
      volumes: image.volumes,
      icon: image.icon
    )
  end

  def self.new_from_params(image_create_params)
    self.new(
      name: "#{image_create_params[:image]}",
      from: "#{image_create_params[:image]}:#{image_create_params[:tag]}",
      ports: image_create_params[:ports],
      expose: image_create_params[:expose],
      environment: image_create_params[:environment],
      volumes: image_create_params[:volumes],
      icon: image_create_params[:icon]
    )
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
