module AppBuilder

  def self.create(options)
    options ||= {}

    strategy = if options.key?(:template_id)
                 AppBuilder::FromTemplate
               else
                 AppBuilder::FromImage
               end

    strategy.create_app(options)
  end

end
