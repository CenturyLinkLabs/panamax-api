module JobTemplateBuilder

  def self.create(options, persisted=true)
    JobTemplateBuilder::FromJson.new(options).create_template(persisted)
  end

end
