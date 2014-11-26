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

  subject { described_class.new(name: 'foo') }

  before do
    subject.manager = dummy_manager
  end

  describe 'validations' do
    it { should belong_to(:app) }
    it { should have_many(:service_categories) }
    it { should have_many(:categories).dependent(:destroy).class_name('ServiceCategory') }
    it { should have_many(:links).dependent(:destroy) }
    it { should have_many(:linked_from_links).dependent(:destroy) }

    it 'can be valid' do
      subject.name = 'valid'
      subject.ports = [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 81, 'container_port' => 7070 }
      ]

      expect(subject.valid?).to be_truthy
      expect(subject.errors).to be_empty
    end

    it 'validates presence of container_port' do
      subject.ports = [
        { host_port: 80 },
        { host_port: 70 }
      ]
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:ports]).to eq ["container port can't be blank"]
    end

    it 'validates uniqueness of host_ports' do
      subject.ports = [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 80, 'container_port' => 7070 }
      ]
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:ports]).to eq ['host ports must be unique']
    end

    context 'when ports are nil' do

      before do
        subject.ports = nil
      end

      it { should be_valid }
    end
  end

  it_behaves_like 'a docker runnable model'
  it_behaves_like 'a classifiable model'

  describe '#unit_name' do
    it 'postfixes the internal_name with .service' do
      subject.internal_name = 'wordpress'
      expect(subject.unit_name).to eq 'wordpress.service'
    end
  end

  describe '#service_state' do
    it 'returns the service state from the service manager' do
      expect(subject.service_state).to eql(load_state: 'loaded')
    end
  end

  describe 'before_create callback' do
    describe '#internal_name' do
      it 'is set to the service name' do
        service = described_class.create(name: 'foobar')
        expect(service.internal_name).to eq(service.name)
      end

      it 'does not change with subsequent updates to the service' do
        service = described_class.create(name: 'foobar')
        service.update(name: 'new_name')
        expect(service.internal_name).to eq('foobar')
      end
    end
  end

  describe 'after initialization' do

    describe '#name=' do

      let(:image_name) { 'foo/bar' }
      let(:bad_name) { 'Foo123_- ~!@#$%&*()+={}|:;"\'<>,?^`][ -890baR' }

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
        expected_name = 'Foo123_-_____________________________-890baR'
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

  describe '#default_exposed_ports' do

    context 'when default exposed ports exist' do

      let(:image_status) do
        double(:image_status,
               info: {
                 'Config' => {
                   'ExposedPorts' => { '3000/tcp' => {} }
                 }
               })
      end

      before do
        Docker::Image.stub(:get).and_return(image_status)
      end

      it 'queries the Docker API with the base image name' do
        expect(Docker::Image).to receive(:get).with(subject.from)
        subject.default_exposed_ports
      end

      it 'assigns each exposed port to an array' do
        expect(subject.default_exposed_ports).to match_array %w(3000/tcp)
      end
    end

    context 'when default exposed ports exist' do

      let(:image_status) do
        double(:image_status,
               info: {
                 'Config' => {
                   'ExposedPorts' => nil
                 }
               })
      end

      before do
        Docker::Image.stub(:get).and_return(image_status)
      end

      it 'queries the Docker API with the base image name' do
        expect(Docker::Image).to receive(:get).with(subject.from)
        subject.default_exposed_ports
      end

      it 'returns an empty array' do
        expect(subject.default_exposed_ports).to be_a(Array)
        expect(subject.default_exposed_ports.length).to eql(0)
      end
    end

    context 'when there is a Docker error' do

      before do
        Docker::Image.stub(:get).and_raise(Docker::Error::DockerError)
      end

      it 'queries the Docker API with the base image name' do
        expect(Docker::Image).to receive(:get).with(subject.from)
        subject.default_exposed_ports
      end

      it 'returns an empty array' do
        expect(subject.default_exposed_ports).to be_a(Array)
        expect(subject.default_exposed_ports.length).to eql(0)
      end
    end

  end

  describe '#update_with_relationships' do

    let(:attrs) { { name: 'new_name' } }

    before do
      subject.stub(:update).and_return(true)
    end

    context 'when volumes are not provided' do
      it 'updates with an empty volumes list' do
        expect(subject).to receive(:update).with(hash_including(volumes: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when volumes are provided' do

      let(:attrs_with_volumes) do
        attrs.merge(volumes:
          [ActionController::Parameters.new(container_volume: 'foo/bar')])
      end

      it 'passes the volumes through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_volumes))
        subject.update_with_relationships(attrs_with_volumes)
      end

      it 'translates the volumes into a pure Ruby hash' do
        expect(subject).to receive(:update) do |attrs|
          attrs[:volumes].each { |volume| expect(volume).to be_instance_of(Hash) }
        end

        subject.update_with_relationships(attrs_with_volumes)
      end
    end

    context 'when volumes_from are not provided' do
      it 'updates with an empty volumes_from list' do
        expect(subject).to receive(:update).with(hash_including(volumes_from: []))
        subject.update_with_relationships(attrs)
      end

    end

    context 'when volumes_from are provided' do
      let(:attrs_with_volumes_from) do
        attrs.merge(
            volumes_from: [{ service_id: 1 }]
        )
      end

      let(:shared_volume) { SharedVolume.new(exported_from_service_id: 1) }

      before do
        subject.stub_chain(:volumes_from, :find_or_initialize_by).and_return(shared_volume)
      end

      it 'populates the related shared volumes' do
        expect(subject).to receive(:update).with(hash_including(volumes_from: [shared_volume]))
        subject.update_with_relationships(attrs_with_volumes_from)
      end
    end

    context 'when ports are not provided' do
      it 'updates with an empty ports list' do
        expect(subject).to receive(:update).with(hash_including(ports: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when ports are provided' do

      let(:attrs_with_ports) do
        attrs.merge(ports:
          [ActionController::Parameters.new(container_port: '8080')])
      end

      it 'passes the ports through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_ports))
        subject.update_with_relationships(attrs_with_ports)
      end

      it 'translates the ports into a pure Ruby hash' do
        expect(subject).to receive(:update) do |attrs|
          attrs[:ports].each { |port| expect(port).to be_instance_of(Hash) }
        end

        subject.update_with_relationships(attrs_with_ports)
      end
    end

    context 'when expose is provided' do

      let(:attrs_with_expose) { attrs.merge(expose: ['9999']) }

      it 'passes expose through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_expose))
        subject.update_with_relationships(attrs_with_expose)
      end
    end

    context 'when expose vars are not provided' do
      it 'updates with an empty array' do
        expect(subject).to receive(:update).with(hash_including(expose: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when environment vars are not provided' do
      it 'updates with an empty env variable hash' do
        expect(subject).to receive(:update).with(hash_including(environment: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when environment variables are provided' do

      let(:attrs_with_env_vars) do
        attrs.merge(environment:
          [ActionController::Parameters.new('variable' => 'X', 'value' => 'y')])
      end

      it 'passes the ports through to the update' do
        expect(subject).to receive(:update).with(hash_including(attrs_with_env_vars))
        subject.update_with_relationships(attrs_with_env_vars)
      end

      it 'translates the environment variables into a pure Ruby hash' do
        expect(subject).to receive(:update) do |attrs|
          attrs[:environment].each { |var| expect(var).to be_instance_of(Hash) }
        end

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
          links: [{ service_id: 1, alias: 'DB' }]
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

    context 'when categories are not provided' do
      it 'updates with an empty categories list' do
        expect(subject).to receive(:update).with(hash_including(categories: []))
        subject.update_with_relationships(attrs)
      end
    end

    context 'when categories are provided' do

      let(:attrs_with_categories) do
        attrs.merge(
          categories: [{ id: 1, position: 5 }]
        )
      end

      let(:service_category) { ServiceCategory.new }

      before do
        subject.stub_chain(:categories, :find_or_initialize_by).and_return(service_category)
      end

      it 'looks for matching ServiceCategory' do
        expect(subject.categories).to receive(:find_or_initialize_by).with(
          app_category_id: 1,
          position: 5
        )

        subject.update_with_relationships(attrs_with_categories)
      end

      it 'populates the related categories' do
        expect(subject).to receive(:update).with(hash_including(categories: [service_category]))
        subject.update_with_relationships(attrs_with_categories)
      end
    end

    it 'returns the result of the update' do
      expect(subject.update_with_relationships(attrs)).to eq true
    end

    describe '#name=' do

      let(:service) { Service.create(name: 'foo') }
      let(:attrs_with_bad_name) { { name: 'Foo123_- ~!@#$%&*()+={}|:;"\'<>,?^`][ -890baR' } }

      it 'sanitizes names with bad chars' do
        expected_name = 'Foo123_-_____________________________-890baR'
        service.update_with_relationships(attrs_with_bad_name)
        service.reload
        expect(service.name).to eq(expected_name)
        expect(service.name.length).to eq(expected_name.length)
      end

      it 'appends an incremented count when service with updated name already exists' do
        # simulate existing service
        Service.create(name: 'foo_bar')
        # update service name from 'foo' to 'foo_bar' which already exists
        service.update_with_relationships(name: 'foo_bar')
        service.reload
        expect(service.name).to eq('foo_bar_1')
      end

      it 'appends an incremented count only if name is updated' do
        service.update_with_relationships(description: 'description for foo')
        service.reload
        expect(service.name).to eq('foo')
      end

    end
  end
end
