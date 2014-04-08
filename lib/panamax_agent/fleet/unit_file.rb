
module PanamaxAgent
  module Fleet
    class UnitFile

      OUTPUT_PATH = '/tmp'

      def self.create(service_name, image, links=[], ports={}, volumes={}, envs={})
        Generator.new(service_name, image, ports, volumes, links, envs).create_unit_file
      end

      def initialize(service_name, image, links, ports, volumes, envs)
        # Need to establish binding context for ERB evaluation
        @service_name = service_name
        @image = image
        @links = links
        @ports = ports
        @volumes = volumes
        @envs = envs
      end

      def create_unit_file
        template_path = File.expand_path('templates/service.erb', File.dirname(__FILE__))
        output_file = File.join(OUTPUT_PATH, "#{@service_name}.service")
        content = nil

        File.open(template_path) do |f|
          erb = ERB.new(f.read, safe_level=nil, trim_mode='-')
          content = erb.result(binding)
        end

        File.open(output_file, 'w') { |f| f.write(content) }
        output_file
      end

    end
  end
end
