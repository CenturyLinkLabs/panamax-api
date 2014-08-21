module Converters
  class ServiceConverter

    attr_reader :service

    def initialize(service)
      @service = service
    end

    def to_image
      Image.new(
        name: service.name,
        categories: service_category_names,
        description: service.description,
        source: service.from,
        ports: service.ports,
        links: service_links,
        expose: service.expose,
        environment: service.environment,
        volumes: service.volumes,
        command: service.command,
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
