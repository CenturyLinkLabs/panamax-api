module Converters
  class AppConverter

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def to_template
      images = app.services.map { |service| service_to_image(service) }
      Template.new(name: app.name, documentation: app.documentation, images: images)
    end

    def to_compose
      services = app.services.map { |service| service_to_compose_service(service) }
      Compose.new(name: app.name, services: services)
    end

    private

    def service_to_image(service)
      ServiceConverter.new(service).to_image
    end

    def service_to_compose_service(service)
      ServiceConverter.new(service).to_compose_service
    end

  end
end
