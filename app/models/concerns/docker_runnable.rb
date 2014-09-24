
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
      volumes_from_flag,
      from,
      command
    ].flatten.compact.join(' ').strip
  end

  def docker_status
    Docker::Container.get(name)
  rescue Docker::Error::DockerError
    {}
  end

  private

  def link_flags
    return unless links
    links.map { |link| "--link #{link.link_string}" }
  end

  def port_flags
    return unless ports
    ports.map do |port|
      option = '-p '
      if port['host_interface'] || port['host_port']
        option << "#{port['host_interface']}:" if port['host_interface']
        option << "#{port['host_port']}:" unless port['host_port'].to_s.empty?
      end
      option << "#{port['container_port']}"
      option << '/udp' if port['proto'] && port['proto'].upcase == 'UDP'
      option
    end
  end

  def expose_flags
    return unless expose
    expose.map { |exposed_port| "--expose #{exposed_port}" }
  end

  def environment_flags
    return unless environment
    environment.map { |env| "-e \"#{env['variable']}=#{env['value']}\"" }
  end

  def volume_flags
    return unless volumes
    volumes.map do |volume|
      option = '-v '
      option << "#{volume['host_path']}:" if volume['host_path'].present?
      option << volume['container_path']
      option
    end
  end

  def volumes_from_flag
    return unless volumes_from
    dvols = ''
    volumes_from.map do |data_volumes|
      dvols += " #{data_volumes['container_name']}"
    end
    "--volumes-from#{dvols}" unless dvols.blank?
  end

end
