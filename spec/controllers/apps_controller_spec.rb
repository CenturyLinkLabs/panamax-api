require 'spec_helper'

describe AppsController do

  describe '#index' do

    it 'returns an array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
    end

  end

  describe '#show' do
    it "returns a specific app" do
      get :show, { id: App.first.id, format: :json }
      expect(response.body).to eq (AppSerializer.new(App.first)).to_json
    end

    it 'returns app representations with an array of services in the services attribute' do
      get :show, { id: App.first.id, format: :json }
      expect(JSON.parse(response.body)).to have_key('services')
      expect(JSON.parse(response.body)['services']).to be_an Array
    end

  end

  describe '#create' do

    context 'when the request contains a template id' do

      let(:params){ { template_id: 1 } }
      let(:template){ double(:template, name: 'my_template') }

      before do
        Template.stub(:find).with(params[:template_id]).and_return(template)
      end

      it 'fetches the template for the given template id' do
        expect(Template).to receive(:find).with(params[:template_id]).and_return(template)
        post :create, { template_id: 1, format: :json }
      end

      it 'creates the application from the template' do
        expect(App).to receive(:create_from_template).with(template)
        post :create, { template_id: 1, format: :json }
      end

    end

    context 'when the request contains an image repository' do

      let(:params) do
        HashWithIndifferentAccess.new({
            image: 'foo/bar:baz',
            links: 'SERVICE2',
            ports: '3306:3306',
            expose: '3306',
            environment: 'MYSQL_ROOT_PASSWORD=pass@word01',
            volumes: '/var/panamax:/var/app/panamax'
        })
      end

      it 'creates the application from the image' do
        expect(App).to receive(:create_from_image).with(params)
        post :create, params, format: :json
      end

    end

  end

end