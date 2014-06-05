module Converters
  class AppConverter

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def to_template
      Template.new(name: app.name, documentation: app.documentation) do |template|
        template.images << app.services.map { |service| service_to_image(service) }
      end
    end

    private

    def service_to_image(service)
      ServiceConverter.new(service).to_image
    end
  end
end
