class App < ActiveRecord::Base
  has_many :services, dependent: :destroy
  has_many :categories, class_name: 'AppCategory'

  before_save :resolve_name_conflicts

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
    services = template.images.map do |image|
      service = Service.new_from_image(image)
      service.copy_categories_from_image(image, categories)
      service
    end

    template.images.each do |image|
      if image.links?
        linked_from_service = services.find { |service| service.name == image.name }
        linked_from_service.copy_links_from_image(image, services)
      end
    end

    services
  end

  def resolve_name_conflicts
      unless persisted?
        sanitized_name = name.gsub('/', '_')
        count = App.where('name LIKE ?', "#{sanitized_name}%").count
        self.name = (count > 0) ? "#{sanitized_name}_#{count}" : sanitized_name
      end
  end
end
