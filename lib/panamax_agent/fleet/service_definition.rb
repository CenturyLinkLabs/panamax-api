module PanamaxAgent
  module Fleet
    class ServiceDefinition

      attr_accessor :name
      attr_accessor :description, :after, :requires
      attr_accessor :exec_start_pre, :exec_start, :exec_start_post,
        :exec_reload, :exec_stop, :exec_stop_post, :restart_sec

      def initialize(name, attrs={})
        self.name = name

        self.description = attrs[:description]
        self.after = attrs[:after]
        self.requires = attrs[:requires]

        self.exec_start_pre = attrs[:exec_start_pre]
        self.exec_start = attrs[:exec_start]
        self.exec_start_post = attrs[:exec_start_post]
        self.exec_reload = attrs[:exec_reload]
        self.exec_stop = attrs[:exec_stop]
        self.exec_stop_post = attrs[:exec_stop_post]
        self.restart_sec = attrs[:restart_sec]
      end

      def to_json
        {
          'Name' => name.end_with?('.service') ? name : "#{name}.service",
          'Unit' => {
            'Contents' => {
              'Unit' => unit_def,
              'Service' => service_def
            }
          }
        }.to_json
      end

      private

      def unit_def
        block = {}

        block['Description'] = description if description

        if after
          block['After'] = after.is_a?(Enumerable) ? after.join(' ') : after
        end

        if requires
          block['Requires'] = requires.is_a?(Enumerable) ? requires.join(' ') : requires
        end

        block
      end

      def service_def
        block = {}
        block['ExecStartPre'] = exec_start_pre if exec_start_pre
        block['ExecStart'] = exec_start if exec_start
        block['ExecStartPost'] = exec_start_post if exec_start_post
        block['ExecReload'] = exec_reload if exec_reload
        block['ExecStop'] = exec_stop if exec_stop
        block['ExecStopPost'] = exec_stop_post if exec_stop_post
        block['RestartSec'] = restart_sec if restart_sec

        block
      end

    end
  end
end
