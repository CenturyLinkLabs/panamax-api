module Converters
  class ServiceConverter

    delegate :categories, :name, :description, :repository, :tag, :ports, :expose, :environment, :volumes,
             :links, :icon, to: :@service

    def initialize(service)
      @service = service
    end

    def to_image
      Image.create(
          name: name,
          categories: service_category_names,
          description: description,
          repository: repository,
          tag: tag,
          ports: ports,
          links: service_links,
          expose: expose,
          environment: environment,
          volumes: volumes,
          icon: icon
      )
    end

    private
    def service_category_names
      categories.map(&:name)
    end

    def service_links
      links.map{ |link| {'service' => link.linked_to_service.name, 'alias' => link.alias} }
    end
  end
end
