require 'spec_helper'

describe App do
  it { should have_many(:services) }

  describe '.create_from_template' do
    it 'creates a new app using values from the template' do
      template = Template.where(name: 'wordpress').first
      expect(App).to receive(:create).with(name: template.name, from: "Template: #{template.name}").and_return(true)
      App.create_from_template(template)
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
      expect(App).to receive(:create).with(name: params[:image], from: "Image: #{params[:image]}")
      App.create_from_image(params)
    end
  end
end