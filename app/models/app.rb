class App < ActiveRecord::Base
  has_many :services, dependent: :destroy
  has_many :categories, class_name: 'AppCategory'

  validates_uniqueness_of :name

  def self.create_from_template(t)

    # BARF BARF BARF

    categories = t.categories.map { |cat| AppCategory.new(name: cat.name) }

    services = t.images.map do |image|
      service = Service.new_from_image(image)
      image.categories.each do |image_cat|
        service.categories << categories.find { |cat| cat.name == image_cat.name }
      end
      service
    end


    self.create(name: t.name, from: "Template: #{t.name}", services: services, categories: categories)
  end

  def self.create_from_image(image_create_params)
    service = Service.new_from_params(image_create_params)
    self.create(name: image_create_params[:image],
                from: "Image: #{image_create_params[:image]}",
                services: [service]
    )
  end
end
