require 'spec_helper'

shared_examples 'a docker runnable model' do
  let(:name) { 'FOO' }
  let(:from) { 'panamax/image' }

  let(:model) { described_class.new(name: name, from: from) }

  context '#docker_run_string' do
    context 'when no options specified' do

      it 'generates the correct docker command' do
        expected = "/usr/bin/docker run --rm --name #{name} #{from}"
        expect(model.docker_run_string).to eq expected
      end
    end

    context 'when links are specified' do

      before do
        linked_to_service = Service.new(name: 'MYSQL')
        link = ServiceLink.new(linked_to_service: linked_to_service, alias: 'DB')
        model.links << link
      end

      it 'generates a docker command with --link' do
        expected = '--link MYSQL:DB'
        expect(model.docker_run_string).to include expected
      end
    end

    context 'when ports are specified' do

      before do
        model.ports = [{
          'host_interface' => '0.0.0.0',
          'host_port' => '8000',
          'container_port' => '3000',
        }]
      end

      it 'generates a docker command with -p' do
        expected = '-p 0.0.0.0:8000:3000'
        expect(model.docker_run_string).to include expected
      end

      context 'when the host_port is empty' do

        before do
          model.ports = [{
                           'host_interface' => nil,
                           'host_port' => '',
                           'container_port' => '3000',
                         }]
        end

        it 'does not include the colon affixed to the host port info' do
          expected = '-p 3000'
          expect(model.docker_run_string).to include expected
        end
      end


      context 'when the UDP protocol is specified' do

        before do
          model.ports = [{
            'container_port' => '3000',
            'proto' => 'udp',
          }]
        end

        it 'generates a docker command with -p with the udp protocol' do
          expected = '-p 3000/udp'
          expect(model.docker_run_string).to include expected
        end
      end

      context 'when the TCP protocol is specified' do

        before do
          model.ports = [{
            'container_port' => '3000',
            'proto' => 'tcp',
          }]
        end

        it 'generates a docker command with -p with no protocol' do
          expected = '-p 3000'
          expect(model.docker_run_string).to include expected
        end
      end
    end

    context 'when a command is specified' do

      before do
        model.command = '/run web'
      end

      it 'generates a docker run string with a command at the end' do
        expected = '/run web'
        expect(model.docker_run_string).to include expected
      end
    end

    context 'when exposed ports are specified' do

      before do
        model.expose = ['8080']
      end

      it 'generates a docker command with --expose' do
        expected = '--expose 8080'
        expect(model.docker_run_string).to include expected
      end
    end

    context 'when environment vars are specified' do

      before do
        model.environment = [{ 'variable' => 'foo', 'value' => 'bar' }]
      end

      it 'generates a docker command with -e' do
        expected = '-e "foo=bar"'
        expect(model.docker_run_string).to include expected
      end
    end

    context 'when volumes are specified' do

      before do
        model.volumes = [{ 'host_path' => '/tmp/foo', 'container_path' => '/tmp/bar' }]
      end

      it 'generates a docker command with -v' do
        expected = '-v /tmp/foo:/tmp/bar'
        expect(model.docker_run_string).to include expected
      end

      it 'excludes the : if only a container volume is specified' do
        model.volumes.first['host_path'] = ''
        expected = '-v /tmp/bar'
        expect(model.docker_run_string).to include expected
      end
    end

    context 'when volumes_from is specified' do

      before do
        model.volumes_from = [{ 'container_name' => 'foodata' }, { 'container_name' => 'bardata' }]
      end

      it 'generates a docker command with --volumes-from' do
        expected = '--volumes-from foodata bardata'
        expect(model.docker_run_string).to include expected
      end
    end

  end

  describe '#docker_status' do

    context 'when the docker API responds successfully' do

      let(:response) { { status: 'ALLGOOD' } }

      before do
        Docker::Container.stub(:get).and_return(response)
      end

      it 'queries the Docker API with the service name' do
        expect(Docker::Container).to receive(:get).with(name)
        model.docker_status
      end

      it 'returns the Docker info for the container' do
        expect(model.docker_status).to eq response
      end
    end

    context 'when the docker API returns an error' do

      before do
        Docker::Container.stub(:get).and_raise(Docker::Error::DockerError)
      end

      it 'returns an empty hash' do
        expect(model.docker_status).to eq({})
      end
    end
  end
end
