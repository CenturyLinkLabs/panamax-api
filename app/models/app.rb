class App < ActiveRecord::Base
  has_many :services, dependent: :destroy

  validates_uniqueness_of :name

  def self.create_from_template(t)
    services = t.images.map { |image| Service.new_from_image(image) }
    self.create(name: t.name, from: "Template: #{t.name}", services: services)
  end

  def self.create_from_image(image_create_params)
    service = Service.new_from_params(image_create_params)
    self.create(name: image_create_params[:image],
                from: "Image: #{image_create_params[:image]}",
                services: [service]
    )
  end
end
