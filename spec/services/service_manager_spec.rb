require 'spec_helper'

describe ServiceManager do

  let(:service_name) { 'wordpress' }
  let(:image_name) { 'some_image' }
  let(:service_description) { 'A wordpress service' }
  let(:service_state) do
    {
      'node' => {
        'value' => '{"loadState":"loaded"}'
      }
    }
  end

  let(:fake_fleet_client) do
    double(
      :fake_fleet_client,
      submit: true,
      load: true,
      start: true,
      stop: true,
      destroy: true
    )
  end

  let(:service) do
    Service.new(
      name: service_name,
      description: service_description,
      from: image_name
    )
  end

  subject { described_class.new(service) }

  before do
    allow(Fleet).to receive(:new).and_return(fake_fleet_client)
  end

  describe '.load' do

    let(:dummy_manager) { double(:dummy_manager, load: true) }

    before do
      allow(described_class).to receive(:new).and_return(dummy_manager)
    end

    it 'news an instance of itself' do
      expect(described_class).to receive(:new).with(service).and_return(dummy_manager)
      described_class.load(service)
    end

    it 'invokes load on manager instance' do
      expect(dummy_manager).to receive(:load)
      described_class.load(service)
    end
  end

  describe '.start' do

    let(:dummy_manager) { double(:dummy_manager, start: true) }

    before do
      allow(described_class).to receive(:new).and_return(dummy_manager)
    end

    it 'news an instance of itself' do
      expect(described_class).to receive(:new).with(service).and_return(dummy_manager)
      described_class.start(service)
    end

    it 'invokes start on manager instance' do
      expect(dummy_manager).to receive(:start)
      described_class.start(service)
    end
  end

  describe '#submit' do

    let(:linked_to_service) { Service.new(name: 'linked_to_service') }
    let(:docker_run_string) { 'docker run some stuff' }

    before do
      service.links << ServiceLink.new(
        alias: 'DB',
        linked_to_service: linked_to_service
      )
      allow(service).to receive(:docker_run_string).and_return(docker_run_string)
    end

    it 'submits a service definition to the fleet service' do
      expect(fake_fleet_client).to receive(:submit) do |name, service_def|
        expect(name).to eq service.unit_name
        expect(service_def).to eq(
          {
            'Unit' => {
              'Description' => service_description,
              'After' => linked_to_service.unit_name,
              'Requires' => linked_to_service.unit_name,
            },
            'Service' => {
              'ExecStartPre' => "-/usr/bin/docker pull #{image_name}",
              'ExecStart' => docker_run_string,
              'ExecStartPost' => "-/usr/bin/docker rm #{service_name}",
              'ExecStop' => "-/usr/bin/docker kill #{service_name}",
              'ExecStopPost' => "-/usr/bin/docker rm #{service_name}",
              'Restart' => 'always',
              'RestartSec' => '10',
              'TimeoutStartSec' => '5min'
            }
          }
        )
      end

      subject.submit
    end

    it 'returns the result of the fleet call' do
      expect(subject.submit).to eql true
    end
  end

  describe '#load' do
    before do
      allow(fake_fleet_client).to receive(:get_unit_state)
        .and_return('systemdLoadState' => 'loaded')
    end

    it 'sends a destroy message to the fleet client' do
      expect(fake_fleet_client).to receive(:load).with(service.unit_name)
      subject.load
    end

    it 'polls the unit state' do
      expect(fake_fleet_client).to receive(:get_unit_state)
        .and_return('systemdLoadState' => 'loaded')
      subject.load
    end

    it 'returns the result of the fleet call' do
      expect(subject.load).to eql true
    end
  end

  [:start, :stop].each do |method|

    describe "##{method}" do

      it "sends a #{method} message to the fleet client" do
        expect(fake_fleet_client).to receive(method).with(service.unit_name)
        subject.send(method)
      end

      it 'returns the result of the fleet call' do
        expect(subject.send(method)).to eql true
      end
    end
  end

  describe '#destroy' do
    before do
      allow(fake_fleet_client).to receive(:get_unit_state)
        .and_raise(Fleet::NotFound, 'oops')
    end

    it 'sends a destroy message to the fleet client' do
      expect(fake_fleet_client).to receive(:destroy).with(service.unit_name)
      subject.destroy
    end

    it 'polls the unit state' do
      expect(fake_fleet_client).to receive(:get_unit_state)
        .and_raise(Fleet::NotFound, 'oops')
      subject.destroy
    end

    it 'returns the result of the fleet call' do
      expect(subject.destroy).to eql true
    end
  end

  describe '#get_state' do

    let(:fleet_state) do
      { load: 'loaded', run: 'running' }
    end

    before do
      allow(fake_fleet_client).to receive(:status).and_return(fleet_state)
    end

    it 'retrieves service state from the fleet client' do
      expect(fake_fleet_client).to receive(:status).with(service.unit_name)
      subject.get_state
    end

    it 'returns the states' do
      expect(subject.get_state).to eq(load: 'loaded', run: 'running')
    end

    context 'when an error occurs while querying fleet' do

      before do
        allow(fake_fleet_client).to receive(:status).and_raise('boom')
      end

      it 'returns an empty hash' do
        expect(subject.get_state).to eql({})
      end
    end
  end
end
