
class AppExecutor
  include Singleton

  def self.run(app)
    new(app).run
  end

  def initialize(app)
    @app = app
  end

  def run
    @app.services.each { |service| fleet_client.submit(service_def_from_service(service)) }
    @app.services.each { |service| fleet_client.start(service.unit_name) }
  end

  private

  def fleet_client
    PanamaxAgent.fleet_client
  end

  REMOVE_EXITED_CONTAINERS = '/usr/bin/docker ps -a -q | xargs docker rm'

  def service_def_from_service(service)
    sd = PanamaxAgent::Fleet::ServiceDefinition.new(service.unit_name)
    sd.description = service.description

    # Collect service dependencies
    dep_services = service.links.map { |link| "#{link[:service]}.service" }.join(' ')
    sd.after = dep_services
    sd.requires = dep_services

    sd.exec_start_pre = REMOVE_EXITED_CONTAINERS
    sd.exec_start = generate_docker_run(service)
    sd.exec_start_post = REMOVE_EXITED_CONTAINERS
    sd.exec_stop = "/usr/bin/docker kill #{service.name} ; /usr/bin/docker rm #{service.name}"
    sd.exec_stop_post = REMOVE_EXITED_CONTAINERS
    sd.restart_sec = '10'
    sd
  end

  def generate_docker_run(service)

    links = service.links.collect do |link|
      " --link #{link[:service]}:#{link[:alias]}"
    end

    ports = service.ports.collect do |port|
      option = " -p "
      if port[:host_interface] || port[:host_port]
        option += "#{port[:host_interface]}:" if port[:host_interface]
        option += "#{port[:host_port]}" if port[:host_port]
        option += ':'
      end
      option += "#{port[:container_port]}"
      option += "/#{port[:proto]}" if port[:proto]
      option
    end

    expose = service.expose.collect do |exposed_port|
      " --expose #{exposed_port}"
    end

    environment = service.environment.collect do |k,v|
      " -e \"#{k}=#{v}\""
    end

    volumes = service.volumes.collect do |volume|
      " -v #{volume[:host_path]}:#{volume[:container_path]}"
    end

    cmd = '/usr/bin/docker run '
    cmd += ' --rm'
    cmd += " --name #{service.name}"
    cmd += links.join(' ')
    cmd += ports.join(' ')
    cmd += expose.join(' ')
    cmd += environment.join(' ')
    cmd += volumes.join(' ')
    cmd += " #{service.from}"
    puts cmd
    cmd
  end

end
