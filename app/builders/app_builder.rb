module AppBuilder

  def self.create(options)
    options ||= {}

    strategy = if options.key?(:template_id)
                 AppBuilder::FromTemplate
               elsif options.key?(:compose_yaml)
                 AppBuilder::FromCompose
               else
                 AppBuilder::FromImage
               end

    strategy.create_app(options)
  end

end
