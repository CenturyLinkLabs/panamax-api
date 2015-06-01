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

    def to_compose_yaml
      compose_hash = app.services.each_with_object({}) do |service, hash|
        hash.merge!(ServiceConverter.new(service).to_compose_hash)
      end
      compose_hash.to_yaml
    end

    private

    def service_to_image(service)
      ServiceConverter.new(service).to_image
    end
  end
end
