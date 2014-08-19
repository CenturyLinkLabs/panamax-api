require 'fleet'

class ServiceManager

  def self.load(service)
    new(service).load
  end

  def self.start(service)
    new(service).start
  end

  def initialize(service)
    @service = service
  end

  def load
    fleet_client.load(@service.unit_name, service_def_from_service(@service))
  end

  def start
    fleet_client.start(@service.unit_name)
  end

  def stop
    fleet_client.stop(@service.unit_name)
  end

  def destroy
    fleet_client.destroy(@service.unit_name)
  end

  def get_state
    fleet_client.status(@service.unit_name)
  rescue
    {}
  end

  private

  def fleet_client
    Fleet.new
  end

  def service_def_from_service(service)

    unit_block = {
      'Description' => service.description
    }

    if service.links.any?
      dep_services = service.links.map do |link|
        link.linked_to_service.unit_name
      end.join(' ')

      unit_block['After'] = dep_services
      unit_block['Requires'] = dep_services
    end

    docker_rm = "-/usr/bin/docker rm #{service.name}"
    service_block = {
      'ExecStartPre' => "-/usr/bin/docker pull #{service.from}",
      'ExecStart' => service.docker_run_string,
      'ExecStartPost' => docker_rm,
      'ExecStop' => "/usr/bin/docker kill #{service.name}",
      'ExecStopPost' => docker_rm,
      'Restart' => 'always',
      'RestartSec' => '10',
      'TimeoutStartSec' => '5min'
    }

    {
      'Unit' => unit_block,
      'Service' => service_block
    }
  end
end
