module Converters
  class ServiceConverter

    attr_reader :service

    def initialize(service)
      @service = service
    end

    def to_image
      Image.create(
          name: service.name,
          categories: service_category_names,
          description: service.description,
          repository: service.repository,
          tag: service.tag,
          ports: service.ports,
          links: service_links,
          expose: service.expose,
          environment: service.environment,
          volumes: service.volumes,
          type: service.type
      )
    end

    private

    def service_category_names
      service.categories.map(&:name)
    end

    def service_links
      service.links.map { |link| { 'service' => link.linked_to_service.name, 'alias' => link.alias } }
    end
  end
end
