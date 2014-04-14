require 'spec_helper'

describe App do
  it { should have_many(:services) }

  let(:fake_services_relation) { double(:fake_services_relation) }
  let(:app){ double(:app, services: fake_services_relation) }

  describe '.create_from_template' do
    let(:template) { Template.where(name: 'wordpress').first }

    it 'creates a new app using values from the template' do
      expect(App).to receive(:create).with(name: template.name, from: "Template: #{template.name}").and_return(true)
      App.create_from_template(template)
    end

    context 'with an associated image' do
      let(:associated_image) do
        Image.new({
          name: 'MySql',
          description: 'a database',
          repository: 'foo',
          tag: 'bar',
          links: [],
          ports: ['8080'],
          expose: ['expose this'],
          environment: {var: 'val'},
          volumes: ['volumes']
        })
      end

      before do
        template.images << associated_image
        App.stub(:create).and_return(app)
      end

      it 'creates a service for each image' do
        fake_services_relation.should_receive(:create).with({
          name: "MySql",
          description: "a database",
          from: "foo:bar",
          links: [],
          ports: ["8080"],
          expose: ["expose this"],
          environment: {:var=>"val"},
          volumes: ["volumes"]
        })
        App.create_from_template(template)
      end
    end
  end

  describe '.create_from_image' do
    let(:params) do
      {
          image: 'foo/bar:baz',
          links: 'SERVICE2',
          ports: '3306:3306',
          expose: '3306',
          environment: 'MYSQL_ROOT_PASSWORD=pass@word01',
          volumes: '/var/panamax:/var/app/panamax'
      }
    end

    it 'creates a new app' do
      fake_services_relation.stub(:create)
      expect(App).to receive(:create).with(name: params[:image], from: "Image: #{params[:image]}").and_return(app)
      App.create_from_image(params)
    end
  end
end
