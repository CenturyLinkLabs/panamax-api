class App < ActiveRecord::Base
  has_many :services, dependent: :destroy
  has_many :categories, class_name: 'AppCategory'

  validates_uniqueness_of :name

  def self.create_from_template(t)
    categories = t.categories.map { |cat| AppCategory.new(name: cat.name) }

    app = self.create(name: t.name, from: "Template: #{t.name}")
    app.categories = categories
    app.services = create_services(t, categories)
    app.save
    app
  end

  def self.create_from_image(image_create_params)
    service = Service.new_from_params(image_create_params)
    self.create(name: image_create_params[:image],
                from: "Image: #{image_create_params[:image]}",
                services: [service]
    )
  end

  private

  def self.create_services(template, categories)
    template.images.map do |image|
      service = Service.new_from_image(image)
      service.copy_categories_from_image(image, categories)
      service
    end
  end
end
