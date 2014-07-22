module TemplateBuilder
  class FromApp

    attr_reader :app_id, :options

    def initialize(app_id, options)
      @app_id = app_id
      @options = options
    end

    def create_template(persisted=true)
      app = App.find(app_id)
      Converters::AppConverter.new(app).to_template.tap do |template|
        template.assign_attributes(options)
        template.save if persisted
      end
    end

  end
end
