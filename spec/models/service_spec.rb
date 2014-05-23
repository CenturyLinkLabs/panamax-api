require 'spec_helper'

describe Service do

  let(:dummy_manager) do
    double(:dummy_manager,
      load: true,
      start: true,
      destroy: true,
      get_state: { load_state: 'loaded' }
    )
  end

  subject{ described_class.new(name:'foo') }

  before do
    subject.manager = dummy_manager
  end

  describe 'validations' do
    it { should belong_to(:app) }
    it { should have_many(:service_categories) }
    it { should have_many(:categories).through(:service_categories).source(:app_category) }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_many(:linked_from_links).dependent(:destroy) }

    it 'can be valid' do
      subject.name = 'valid'
      subject.ports = [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 81, 'container_port' => 7070 }
      ]

      expect(subject.valid?).to be_true
      expect(subject.errors).to be_empty
    end

    it 'validates presence of container_port' do
      subject.ports = [
        { host_port: 80 },
        { host_port: 70 }
      ]
      expect(subject.valid?).to be_false
      expect(subject.errors[:ports]).to eq ["container port can't be blank"]
    end

    it 'validates uniqueness of host_ports' do
      subject.ports = [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 80, 'container_port' => 7070 }
      ]
      expect(subject.valid?).to be_false
      expect(subject.errors[:ports]).to eq ['host ports must be unique']
    end
  end

  it_behaves_like "a docker runnable model"

  describe '#unit_name' do
    it 'postfixes the name with .service' do
      subject.name = 'wordpress'
      expect(subject.unit_name).to eq 'wordpress.service'
    end
  end

  describe '#service_state' do
    it 'returns the service state from the service manager' do
      expect(subject.service_state).to eql({ load_state: 'loaded' })
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
          volumes: [{host_path: '', container_path: ''}],
          icon: 'someicon.png'
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
      expect(result.icon).to eq 'someicon.png'
    end
  end

  describe "after initialization" do

    describe "#name=" do

      let(:image_name){ 'foo/bar' }
      let(:bad_name){ 'Foo123_- ~!@#$%&*()+={}|:;"\'<>,?^`][ -890baR' }

      it 'replaces slashes with underscores' do
        result = described_class.create(name: image_name)
        expect(result.name).to start_with('foo_bar')
      end

      it 'appends an incremented count' do
        described_class.create(name: image_name)
        result = described_class.create(name: image_name)
        expect(result.name).to eq('foo_bar_1')
      end

      it 'sanitizes names with bad chars' do
        expected_name = "Foo123_-_____________________________-890baR"
        result = described_class.create(name: bad_name)
        expect(result.name).to eq(expected_name)
        expect(result.name.length).to eq(expected_name.length)
      end

    end
  end

  describe '#submit' do
    it 'invokes load on the service manager' do
      expect(dummy_manager).to receive(:load)
      subject.submit
    end
  end

  describe '#start' do
    it 'invokes start on the service manager' do
      expect(dummy_manager).to receive(:start)
      subject.start
    end
  end

  describe '#shutdown' do
    it 'invokes destroy on the service manager' do
      expect(dummy_manager).to receive(:destroy)
      subject.shutdown
    end
  end

  describe '#restart' do
    it 'invokes destroy on the service manager' do
      expect(dummy_manager).to receive(:destroy)
      subject.restart
    end

    it 'invokes load on the service manager' do
      expect(dummy_manager).to receive(:load)
      subject.restart
    end

    it 'invokes start on the service manager' do
      expect(dummy_manager).to receive(:start)
      subject.restart
    end

    context 'when the destroy fails' do

      before do
        dummy_manager.stub(:destroy).and_raise('boom')
      end

      it 'ignores the failure' do
        subject.restart
      end
    end
  end

  describe '#update_with_relationships' do

    let(:attrs) { { name: 'new_name' } }

    before do
      subject.stub(:update).and_return(true)
    end

    context 'when ports are not provided' do
      it 'updates with an empty ports list' do
        expect(subject).to receive(:update).with(hash_including(ports: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when ports are provided' do

      let(:attrs_with_ports) { attrs.merge(ports: [{ container_port: '8080' }]) }

      it 'passes the ports through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_ports))
        subject.update_with_relationships(attrs_with_ports)
      end
    end

    context 'when environment vars are not provided' do
      it 'updates with an empty env variable hash' do
        expect(subject).to receive(:update).with(hash_including(environment: {}))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when environment variables are provided' do

      let(:attrs_with_env_vars) { attrs.merge(environment: { PASSWORD: 'password' }) }

      it 'passes the ports through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_env_vars))
        subject.update_with_relationships(attrs_with_env_vars)
      end
    end

    context 'when links are not provided' do
      it 'updates with an empty links list' do
        expect(subject).to receive(:update).with(hash_including(links: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when links are provided' do

      let(:attrs_with_links) do
        attrs.merge(
          links: [ { service_id: 1, alias: 'DB' } ]
        )
      end

      let(:service_link) { ServiceLink.new(linked_to_service_id: 1, alias: 'DB') }

      before do
        subject.stub_chain(:links, :find_or_initialize_by).and_return(service_link)
      end

      it 'populates the related links' do
        expect(subject).to receive(:update).with(hash_including(links: [service_link]))
        subject.update_with_relationships(attrs_with_links)
      end
    end

    it 'returns the result of the update' do
      expect(subject.update_with_relationships(attrs)).to eq true
    end

    describe "#name=" do

      let(:service) { Service.create(name:'foo') }
      let(:attrs_with_bad_name){ { name: 'Foo123_- ~!@#$%&*()+={}|:;"\'<>,?^`][ -890baR'} }

      it 'sanitizes names with bad chars' do
        expected_name = "Foo123_-_____________________________-890baR"
        service.update_with_relationships(attrs_with_bad_name)
        service.reload
        expect(service.name).to eq(expected_name)
        expect(service.name.length).to eq(expected_name.length)
      end

      it 'appends an incremented count when service with updated name already exists' do
        # simulate existing service
        Service.create({ name: 'foo_bar' })
        # update service name from 'foo' to 'foo_bar' which already exists
        service.update_with_relationships({ name: 'foo_bar' })
        service.reload
        expect(service.name).to eq('foo_bar_1')
      end

      it 'appends an incremented count only if name is updated' do
        service.update_with_relationships({ description: 'description for foo' })
        service.reload
        expect(service.name).to eq('foo')
      end

    end
  end
end
