require 'spec_helper'

describe Service do

  let(:dummy_manager) { double(:dummy_manager, submit: true, start: true) }

  subject{ described_class.new(name:'foo') }

  before do
    subject.manager = dummy_manager
  end

  it { should belong_to(:app) }
  it { should have_many(:service_categories) }
  it { should have_many(:categories).through(:service_categories).source(:app_category) }
  it { should have_many(:links) }

  it_behaves_like "a docker runnable model"

  describe '#unit_name' do
    it 'postfixes the name with .service' do
      subject.name = 'wordpress'
      expect(subject.unit_name).to eq 'wordpress.service'
    end
  end


  describe 'service states' do
    let(:fleet_state) do
      {
          'node' => {
              'value' => '{"loadState":"loaded", "activeState":"active","subState":"running"}'
          }
      }
    end

    let(:fleet_client) do
      double(:fleet_client, get_state: fleet_state)
    end

    before do
      PanamaxAgent.stub(:fleet_client).and_return(fleet_client)
    end

    [:load_state, :active_state, :sub_state].each do |attr|
      it 'invokes the Fleet API' do
        expect(PanamaxAgent.fleet_client).to receive(:get_state).with(subject.unit_name)
        subject.send(attr)
      end
    end

    describe 'load_state' do
      it 'returns loadState from Fleet' do
        expect(subject.load_state).to eq 'loaded'
      end
    end

    describe 'active_state' do
      it 'returns activeState from Fleet' do
        expect(subject.active_state).to eq 'active'
      end
    end

    describe 'sub_state' do
      it 'returns subState from Fleet' do
        expect(subject.sub_state).to eq 'running'
      end
    end

  end

  describe '.new_from_image' do
    let(:fake_image) do
      double(:fake_image, {
          name: 'Apache',
          description: 'a webserver',
          repository: 'ApacheFoundation/Apache',
          tag: 'latest',
          ports: [{host_interface: '', host_port: '', container_port: '', proto: ''}],
          expose: [''],
          environment: {'SOME_KEY' => ''},
          volumes: [{host_path: '', container_path: ''}]
        }
      )
    end

    it 'instantiates a new model with values from the image' do
      result = described_class.new_from_image(fake_image)
      expect(result.name).to eq 'Apache'
      expect(result.description).to eq 'a webserver'
      expect(result.from).to eq 'ApacheFoundation/Apache:latest'
      expect(result.ports).to eq [{host_interface: '', host_port: '', container_port: '', proto: ''}]
      expect(result.expose).to eq ['']
      expect(result.environment).to eq({'SOME_KEY' => ''})
      expect(result.volumes).to eq [{host_path: '', container_path: ''}]
    end
  end

  describe "after initialization" do

    describe "#name=" do

      let(:image_name){ 'foo/bar' }

      it 'replaces slashes with underscores' do
        result = described_class.create(name: image_name)
        expect(result.name).to start_with('foo_bar')
      end

      it 'appends an incremented count' do
        described_class.create(name: image_name)
        result = described_class.create(name: image_name)
        expect(result.name).to eq('foo_bar_1')
      end
    end
  end

  describe '#submit' do
    it 'invokes submit on the service manager' do
      expect(dummy_manager).to receive(:submit)
      subject.submit
    end
  end

  describe '#start' do
    it 'invokes start on the service manager' do
      expect(dummy_manager).to receive(:start)
      subject.start
    end
  end

end
