module TemplateBuilder

  def self.create(options)
    options ||= {}

    if options.kind_of?(String)
      strategy = TemplateBuilder::FromJson.new(options)
    elsif options.has_key?(:app_id)
      app_id = options.delete(:app_id)
      strategy = TemplateBuilder::FromApp.new(app_id, options)
    else
      strategy = TemplateBuilder::FromJson.new(options.to_json)
    end

    strategy.create_template
  end

end

