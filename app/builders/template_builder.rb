module TemplateBuilder

  def self.create(options = {})
    if app_id = options.delete(:app_id)
      strategy = TemplateBuilder::FromApp.new(app_id, options)
    else
      strategy = TemplateBuilder::FromJson.new(options)
    end
    strategy.create_template
  end

end

