class Service < ActiveRecord::Base
  include DockerRunnable

  belongs_to :app
  has_many :service_categories
  has_many :categories, through: :service_categories, source: :app_category

  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Hash
  serialize :volumes, Array

  before_save :sanitize_name

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.new_from_image(image)
    self.new(
      name: image.name,
      description: image.description,
      from: "#{image.repository}:#{image.tag}",
      links: image.links,
      ports: image.ports,
      expose: image.expose,
      environment: image.environment,
      volumes: image.volumes
    )
  end

  def self.new_from_params(image_create_params)
    self.new(name: "#{image_create_params[:image]}",
             from: "#{image_create_params[:image]}:#{image_create_params[:tag]}",
             ports: image_create_params[:ports],
             expose: image_create_params[:expose],
             environment: image_create_params[:environment],
             volumes: image_create_params[:volumes]
    )
  end

  def unit_name
    "#{name}.service"
  end

  def copy_categories_from_image(image, app_categories)
    image.categories.each do |image_cat|
      self.categories << app_categories.find { |app_cat| app_cat.name == image_cat.name }
    end
  end

  private

  def sanitize_name
    sanitized_name = name.gsub('/', '_')
    count = Service.where('name LIKE ?', "#{sanitized_name}%").count
    self.name = "#{sanitized_name}_#{count+1}"
  end

end
