class Service < ActiveRecord::Base
  include DockerRunnable

  belongs_to :app

  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Hash
  serialize :volumes, Array

  before_save :sanitize_name

  validates_presence_of :name
  validates_uniqueness_of :name

  def unit_name
    "#{name}.service"
  end

  def load_state
    service_state['loadState']
  end

  def active_state
    service_state['activeState']
  end

  def sub_state
    service_state['subState']
  end

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

  protected

  def fleet_client
    PanamaxAgent.fleet_client
  end

  private

  def sanitize_name
    sanitized_name = name.gsub('/', '_')
    count = Service.where('name LIKE ?', "#{sanitized_name}%").count
    self.name = "#{sanitized_name}_#{count+1}"
  end

  def service_state
    if not @service_state
      fleet_state = fleet_client.get_state(unit_name)
      @service_state = JSON.parse(fleet_state['node']['value'])
    end
    @service_state
  rescue Exception
    {}
  end

end
