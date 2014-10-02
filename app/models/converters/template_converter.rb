module Converters
  class TemplateConverter

    def initialize(template)
      self.template = template
    end

    def to_app
      # Gather all AppCategories
      self.app_categories =
        template.categories.map { |cat| AppCategory.new(name: cat) }

      # Gather all services
      self.services = template.images.map { |image| service_from_image(image) }

      # Set-up links between services
      template.images.each do |image|
        next unless image.links?
        linked_from_service = find_service(image.name)
        linked_from_service.links = service_links_from_image(image)
      end

      # Set-up shared volumes for services
      template.images.each do |image|
        next unless image.volumes_from?
        the_service = find_service(image.name)
        the_service.volumes_from = shared_volumes_from_image(image)
      end

      App.new(
        name: template.name,
        from: "Template: #{template.name}",
        documentation: template.documentation,
        categories: app_categories,
        services: services
      )
    end

    private

    def service_from_image(image)
      Service.new(
        name: image.name,
        description: image.description,
        from: image.source,
        ports: image.ports,
        expose: image.expose,
        environment: image.environment,
        command: image.command,
        volumes: image.volumes,
        type: image.type,
        categories: service_categories_from_image(image)
      )
    end

    def service_categories_from_image(image)
      image.categories.compact.map do |image_category_name|
        app_category = find_app_category(image_category_name)
        ServiceCategory.new(app_category: app_category)
      end
    end

    def service_links_from_image(image)
      image.links.map do |link|
        ServiceLink.new(
          linked_to_service: find_service(link['service']),
          alias: link['alias']
        )
      end
    end

    def shared_volumes_from_image(image)
      image.volumes_from.map do |vol_from|
        SharedVolume.new(
          exported_from_service: find_service(vol_from['service'])
        )
      end
    end

    def find_service(name)
      services.find { |service| service.name == name }
    end

    def find_app_category(name)
      app_categories.find { |app_cat| app_cat.name == name }
    end

    attr_accessor :template, :app_categories, :services
  end
end
