module Converters
  class ServiceConverter

    attr_reader :service

    def initialize(service)
      @service = service
    end

    def to_image
      Image.new(
        name: service.name,
        categories: service_category_names,
        description: service.description,
        source: service.from,
        ports: service.ports,
        links: service_links,
        expose: service.expose,
        environment: service.environment,
        volumes: service.volumes,
        volumes_from: service_volumes_from,
        command: service.command,
        type: service.type
      )
    end

    def to_compose_hash
      service_attrs = {}

      service_attrs['image'] = service.from
      service_attrs['ports'] = compose_ports
      service_attrs['links'] = compose_links
      service_attrs['expose'] = service.expose
      service_attrs['environment'] = compose_environment
      service_attrs['volumes'] = compose_volume
      service_attrs['volumes_from'] = compose_volumes_from
      service_attrs['command'] = service.command

      { service.name => service_attrs.delete_if { |_, value| value.blank? } }
    end

    concerning :ComposeConversion do
      def compose_ports
        return unless service.ports
        service.ports.map do |port|
          option = ''
          if port['host_interface'] || port['host_port']
            option << "#{port['host_interface']}:" if port['host_interface']
            option << "#{port['host_port']}:" unless port['host_port'].to_s.empty?
          end
          option << "#{port['container_port']}"
          option << '/udp' if port['proto'] && port['proto'].upcase == 'UDP'
          option
        end
      end

      def compose_links
        return unless service.links
        service.links.map(&:link_string)
      end

      def compose_environment
        return unless service.environment
        service.environment.map { |env| "#{env['variable']}=#{env['value']}" }
      end

      def compose_volume
        return unless service.volumes
        service.volumes.map do |volume|
          option = ''
          option << "#{volume['host_path']}:" if volume['host_path'].present?
          option << volume['container_path']
          option
        end
      end

      def compose_volumes_from
        return unless service.volumes_from && service.volumes_from.present?
        service.volumes_from.map(&:exported_from_service_name)
      end
    end

    private

    def service_category_names
      service.categories.map(&:name)
    end

    def service_links
      service.links.map { |link| { 'service' => link.linked_to_service.name, 'alias' => link.alias } }
    end

    def service_volumes_from
      service.volumes_from.map { |shared_vol| { 'service' => shared_vol.exported_from_service.name } }
    end

  end
end
