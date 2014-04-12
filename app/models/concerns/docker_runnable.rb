
module DockerRunnable
  extend ActiveSupport::Concern

  def docker_run_string
    [
      '/usr/bin/docker run',
      '--rm',
      "--name #{name}",
      link_flags,
      port_flags,
      expose_flags,
      environment_flags,
      volume_flags,
      from
    ].flatten.compact.join(' ')
  end

  private

  def link_flags
    if links
      links.collect { |link| "--link #{link[:service]}:#{link[:alias]}" }
    end
  end

  def port_flags
    if ports
      ports.collect do |port|
        option = "-p "
        if port[:host_interface] || port[:host_port]
          option << "#{port[:host_interface]}:" if port[:host_interface]
          option << "#{port[:host_port]}" if port[:host_port]
          option << ':'
        end
        option << "#{port[:container_port]}"
        option << "/#{port[:proto]}" if port[:proto]
        option
      end
    end
  end

  def expose_flags
    if expose
      expose.collect { |exposed_port| "--expose #{exposed_port}" }
    end
  end

  def environment_flags
    if environment
      environment.collect { |k,v| "-e \"#{k}=#{v}\"" }
    end
  end

  def volume_flags
    if volumes
      volumes.collect do |volume|
        "-v #{volume[:host_path]}:#{volume[:container_path]}"
      end
    end
  end

end
