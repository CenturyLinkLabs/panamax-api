require 'spec_helper'

describe Converters::TemplateConverter do

  describe '#to_app' do
    fixtures :templates
    let(:template) { templates(:wordpress) }

    subject { Converters::TemplateConverter.new(template) }

    it 'copies values from the template' do
      app = subject.to_app
      expect(app.name).to eq template.name
      expect(app.from).to eq "Template: #{template.name}"
      expect(app.documentation).to eq template.documentation
    end

    context 'with an associated image' do

      let(:image) do
        Image.new(
          name: 'MySql',
          description: 'a database',
          source: 'foo',
          ports: [{ 'container_port' => '8080' }],
          expose: ['expose this'],
          environment: { var: 'val' },
          command: '/boom shaka',
          volumes: ['volumes'],
          volumes_from: ['service1'],
          type: 'mysql'
        )
      end

      before do
        template.images << image
      end

      it 'creates a service for the image' do
        app = subject.to_app
        expect(app.services.size).to eq 1
      end

      it 'copies the image attributes to the service' do
        app = subject.to_app
        service = app.services.first
        expect(service.name).to eq image.name
        expect(service.description).to eq image.description
        expect(service.from).to eq image.source
        expect(service.ports).to eq image.ports
        expect(service.expose).to eq image.expose
        expect(service.environment).to eq image.environment
        expect(service.command).to eq image.command
        expect(service.volumes).to eq image.volumes
        expect(service.type).to eq image.type
      end

      context 'when an image has a category' do

        before do
          image.categories = ['cat1']
        end

        it 'associates an application category' do
          app = subject.to_app
          expect(app.categories.size).to eq 1
        end

        it 'copies the image category name to the application category' do
          app = subject.to_app
          category = app.categories.first
          expect(category.name).to eq 'cat1'
        end

        it 'associates a service category to the service' do
          app = subject.to_app
          service = app.services.first
          expect(service.categories.size).to eq 1
        end

        it 'associates the service with the correct category' do
          app = subject.to_app
          category = app.services.first.categories.first
          expect(category.name).to eq 'cat1'
          expect(category.app_category.app).to eq app
        end
      end
    end

    context 'with linked images' do

      let(:image1) { Image.new(name: 'I1', source: 'I1:latest') }
      let(:image2) { Image.new(name: 'I2', source: 'I2:latest') }

      before do
        image2.links = [{ 'service' => 'I1', 'alias' => 'FOO' }]
        template.images = [image1, image2]
      end

      it 'creates a service for both images' do
        app = subject.to_app
        expect(app.services.size).to eq 2
      end

      it 'creates service links where appropriate' do
        app = subject.to_app
        s1, s2 = app.services
        expect(s1.links.size).to eq 0
        expect(s2.links.size).to eq 1
      end

      it 'applies the correct alias to the link' do
        app = subject.to_app
        _s1, s2 = app.services
        expect(s2.links.first.alias).to eq image2.links.first['alias']
      end

      it 'links the services correctly' do
        app = subject.to_app
        s1, s2 = app.services
        expect(s2.links.first.linked_to_service).to eq s1
      end
    end

    context 'with shared volumes' do

      let(:image1) { Image.new(name: 'I1', source: 'I1:latest') }
      let(:image2) { Image.new(name: 'I2', source: 'I2:latest') }

      before do
        image2.volumes_from = [{ 'service' => 'I1' }]
        template.images = [image1, image2]
      end

      it 'creates a service for both images' do
        app = subject.to_app
        expect(app.services.size).to eq 2
      end

      it 'creates shared volumes where appropriate' do
        app = subject.to_app
        s1, s2 = app.services
        expect(s1.volumes_from.size).to eq 0
        expect(s2.volumes_from.size).to eq 1
      end

      it 'shared volumes linked to the services correctly' do
        app = subject.to_app
        s1, s2 = app.services
        expect(s2.volumes_from.first.exported_from_service_id).to eq s2.id
        expect(s2.volumes_from.first.mounted_on_service_id).to eq s1.id
      end
    end

  end
end
