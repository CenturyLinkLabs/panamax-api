module JobTemplateBuilder

  def self.create(options)
    JobTemplateBuilder::FromJson.new(options).create_template
  end

end
