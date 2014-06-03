module TemplateBuilder
  class FromJson

    attr_reader :params

    def initialize(json)
      @params = YAML.load(json)
    end

    def create_template
      Template.create(params)
    end

  end
end
