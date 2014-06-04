module Converters
  class AppConverter

    delegate :name, :documentation, :services, to: :@app

    def initialize(app)
      @app = app
    end

    def to_template
      Template.new(name: name, documentation: documentation) do |template|
        template.images << services.map { |service| service_to_image(service) }
      end
    end

    private

    def service_to_image(service)
      ServiceConverter.new(service).to_image
    end
  end
end
