require 'spec_helper'

describe Service do

  subject{ described_class.new(name:'foo') }

  it { should belong_to(:app) }

  it_behaves_like "a docker runnable model"

  describe '#unit_name' do
    it 'postfixes the name with .service' do
      subject.name = 'wordpress'
      expect(subject.unit_name).to eq 'wordpress.service'
    end
  end


  describe '.new_from_image' do
    let(:image_attributes) do

    end

    let(:fake_image) do
      double(:fake_image, {
          name: 'Apache',
          description: 'a webserver',
          repository: 'ApacheFoundation/Apache',
          tag: 'latest',
          links: [{service: 'MYSQL', alias: 'DB'}],
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
      expect(result.links).to eq [{service: 'MYSQL', alias: 'DB'}]
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
        expect(result.name).to eq('foo_bar_2')
      end


    end

  end

end
