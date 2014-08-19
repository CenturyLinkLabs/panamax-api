require 'digest/sha1'

module PanamaxAgent
  module Fleet
    class ServiceDefinition

      attr_accessor :name
      attr_accessor :description, :after, :requires
      attr_accessor :exec_start_pre, :exec_start, :exec_start_post,
        :exec_reload, :exec_stop, :exec_stop_post, :restart, :restart_sec,
        :timeout_start_sec

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
        self.restart = attrs[:restart] || 'always'
        self.restart_sec = attrs[:restart_sec]
        self.timeout_start_sec = attrs[:timeout_start_sec]

        yield self if block_given?
      end

      def unit_def
        {
          'Contents' => {
            'Unit' => unit_block,
            'Service' => service_block
          },
          'Raw' => raw
        }
      end

      def job_def
        {
          'Name' => name,
          'UnitHash' => sha1_byte_array
        }
      end

      def sha1
        Digest::SHA1.hexdigest raw
      end

      private

      def unit_block
        block = {}

        block['Description'] = [description] if description

        if after
          block['After'] = [after.is_a?(Enumerable) ? after.join(' ') : after]
        end

        if requires
          block['Requires'] = [requires.is_a?(Enumerable) ? requires.join(' ') : requires]
        end

        block
      end

      def service_block
        block = {}
        block['ExecStartPre'] = [exec_start_pre] if exec_start_pre
        block['ExecStart'] = [exec_start] if exec_start
        block['ExecStartPost'] = [exec_start_post] if exec_start_post
        block['ExecReload'] = [exec_reload] if exec_reload
        block['ExecStop'] = [exec_stop] if exec_stop
        block['ExecStopPost'] = [exec_stop_post] if exec_stop_post
        block['Restart'] = [restart] if restart
        block['RestartSec'] = [restart_sec] if restart_sec
        block['TimeoutStartSec'] = [timeout_start_sec] if timeout_start_sec

        block
      end

      def raw
        raw_string = ''
        raw_string += "[Unit]\n"
        raw_string += "Description=#{description}\n" if description
        raw_string += "After=#{after}\n" if after
        raw_string += "Requires=#{requires}\n" if requires
        raw_string += "\n"
        raw_string += "[Service]\n"
        raw_string += "ExecStartPre=#{exec_start_pre}\n" if exec_start_pre
        raw_string += "ExecStart=#{exec_start}\n" if exec_start
        raw_string += "ExecStartPost=#{exec_start_post}\n" if exec_start_post
        raw_string += "ExecReload=#{exec_reload}\n" if exec_reload
        raw_string += "ExecStop=#{exec_stop} || true\n" if exec_stop
        raw_string += "ExecStopPost=#{exec_stop_post} || true\n" if exec_stop_post
        raw_string += "Restart=#{restart}\n" if restart
        raw_string += "RestartSec=#{restart_sec}\n" if restart_sec
        raw_string += "TimeoutStartSec=#{timeout_start_sec}\n" if timeout_start_sec
        raw_string
      end

      def sha1_byte_array
        Digest::SHA1.digest(raw).unpack('C20')
      end
    end
  end
end
