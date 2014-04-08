module PanamaxAgent
  module Fleet
    class ServiceDefinition

      attr_accessor :name, :exec

      def initialize(name, exec)
        self.name = name
        self.exec = exec
      end

      def name=(name)
        @name = name.end_with?('.service') ? name : "#{name}.service"
      end

      def to_json
        {
          'Name' => @name,
          'Unit' => {
            'Contents' => {
              'Service' => {
                'ExecStart' => @exec
              },
              'Unit' => {
                'Description' => @name
              }
            }
          }
        }.to_json
      end

    end
  end
end
