require 'spec_helper'

describe App do
  it { should have_many(:services) }

  describe '.create_from_template' do
    let(:template) { Template.where(name: 'wordpress').first }

    it 'creates a new app using values from the template' do
      result = App.create_from_template(template)
      result.reload
      expect(result.name).to eq template.name
      expect(result.from).to eq "Template: #{template.name}"
    end

    context 'with an associated image' do
      let(:associated_image) do
        image_params = {
            name: 'MySql',
            description: 'a database',
            repository: 'foo',
            tag: 'bar',
            links: [],
            ports: ['8080'],
            expose: ['expose this'],
            environment: {var: 'val'},
            volumes: ['volumes']
        }
        Image.new(image_params)
      end

      before do
        template.images << associated_image
      end

      it 'creates a service for each image' do
        expect {
          App.create_from_template(template)
        }.to change { Service.count }.by(1)
      end
    end
  end

  describe '.create_from_image' do

    let(:params) do
      {
          image: 'foo/bar:baz',
          links: [{service: 'MYSQL', alias: 'DB'}],
          ports: [{host_interface: '', host_port: '', container_port: '', proto: ''}],
          expose: ['3306'],
          environment: {'SOME_KEY' => ''},
          volumes: [{host_path: '', container_path: ''}]
      }
    end

    it 'creates a new app from the params' do
      result = App.create_from_image(params)
      result.reload
      expect(result.name).to eq 'foo/bar:baz'
      expect(result.from).to eq 'Image: foo/bar:baz'
    end

    it 'creates a service from the params' do
      expect {
        App.create_from_image(params)
      }.to change { Service.count }.by(1)
    end

    it 'associates the service with the app' do
      result = App.create_from_image(params)
      result.reload
      expect(result.services.count).to eq(1)
      expect(Service.last.app).to eq result
    end

  end
end
