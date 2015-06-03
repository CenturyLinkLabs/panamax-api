module TemplateBuilder
  class FromCompose

    attr_reader :compose_yaml, :options

    def initialize(options)
      @compose_yaml = options.delete('compose_yaml')
      @options = options
    end

    def create_template(persisted=true)
      Template.new(self.options) do |template|
        template.images = images_from_compose if compose_yaml
        template.save if persisted
      end
    end

    private

    def images_from_compose
      compose_services = YAML.safe_load(compose_yaml) || {}
      compose_services.map { |name, service_def| image_from_compose_service(name, service_def) }
    end

    def image_from_compose_service(name, service_def)
      Image.new(name: name) do |image|
        image.source = service_def['image']
        image.links = links(service_def['links'])
        image.ports = ports(service_def['ports'])
        image.expose = Array(service_def['expose'])
        image.volumes = volumes(service_def['volumes'])
        image.environment = environment(service_def['environment'])
        image.volumes_from = shared_volumes(service_def['volumes_from'])
      end
    end

    def links(links_array)
      Array(links_array).map do |link|
        service, prefix = link.split(':')
        # compose allows links without aliases, so we'll default the alias to the linked service name
        prefix ||= service
        %w(service alias).zip([service, prefix]).to_h
      end
    end

    def ports(ports_array)
      Array(ports_array).map do |port|
        %w(host_port container_port).zip(port.split(':')).to_h
      end
    end

    def volumes(volumes_array)
      Array(volumes_array).map do |volume|
        %w(host_path container_path).zip(volume.split(':')).to_h
      end
    end

    def environment(env)
      return unless env
      env.map do |k, v|
        k, v = k.split('=', 2) unless v
        { 'variable' => k, 'value' => v }
      end
    end

    def shared_volumes(vol_from_array)
      Array(vol_from_array).map do |vol_from|
        { 'service' => vol_from }
      end
    end

  end
end
