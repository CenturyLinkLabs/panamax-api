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
      let(:app){ App.new }
      let(:params){ { template_id: 1 } }
      let(:template){ double(:template, name: 'my_template') }

      before do
        App.stub(:create_from_template).and_return(app)
        AppExecutor.stub(:run)
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
        {
            image: 'foo/bar:baz',
            links: [{service: '1', alias: '1'}, {service: '1', alias: '1'}],
            ports: [{host_interface: '', host_port: '', container_port: '', proto: ''}],
            expose: [''],
            environment: { 'SOME_KEY' => ''},
            volumes: [{host_path: '', container_path: ''}],
            tag: 'latest'
        }
      end

      let(:app){ App.new }

      before do
        App.stub(:create_from_image).and_return(app)
        AppExecutor.stub(:run)
      end

      it 'creates the application from the image' do
        expect(App).to receive(:create_from_image).with(params.stringify_keys!).and_return(app)
        post :create, params.merge(format: :json)
      end

    end

    context 'when attempting to run the application raises an exception' do
      let(:app){ apps(:app1) } # load from fixture to get services assoc
      let(:params){ { template_id: 1 } }
      let(:template){ double(:template, name: 'my_template') }

      before do
        App.stub(:create_from_template).and_return(app)
        PanamaxAgent::Fleet::Client.any_instance.stub(:destroy).and_return true
        AppExecutor.stub(:run).and_raise('boom')
        Template.stub(:find)
      end

      it 'destroys the app' do
        post :create, params.merge(format: :json)
        expect(App.where(id: app.id).first).to be_nil
      end

      it 'destroys the app services' do
        post :create, params.merge(format: :json)
        expect(Service.where(app_id: app.id)).to be_empty
      end

      it 'returns 422 error' do
        post :create, params.merge(format: :json)
        expect(response.status).to eq(422) # :unprocessable_entity
      end

      it 'renders the error in the json body' do
        post :create, params.merge(format: :json)
        expect(JSON.parse(response.body)).to have_key('errors')
      end

    end

    context 'when the app name is already in use' do

      let(:app){ App.create(name: apps(:app1).name) }
      let(:params){ { template_id: 1 } }
      let(:template){ double(:template, name: 'my_template') }

      before do
        App.stub(:create_from_template).and_return(app)
        AppExecutor.stub(:run)
        Template.stub(:find).with(params[:template_id]).and_return(template)
      end

      it 'persists the app with a new name' do
        post :create, params.merge(format: :json)
        expect(app.persisted?).to be_true
      end

      it 'the app has a new name' do
        post :create, params.merge(format: :json)
        expect(app.name).to eq("App 1_1")
      end

      it 'returns no errors' do
        post :create, params.merge(format: :json)
        expect(response.status).to eq 200
      end

    end

    context 'when the app is updated with a category' do
      let(:app){ App.create(name: apps(:app1).name) }
      let(:params){ { template_id: 1 } }
      let(:template){ double(:template, name: 'my_template') }

      before do
        App.stub(:create_from_template).and_return(app)
        AppExecutor.stub(:run)
        Template.stub(:find).with(params[:template_id]).and_return(template)
      end

      it 'the name is not affected' do
        post :create, params.merge(format: :json)
        app.categories = [AppCategory.new(name: 'My Category')]
        app.save
        app.reload
        expect(app.name).to eq("App 1_1")
      end

    end
  end

  describe '#destroy' do
    let(:app){ apps(:app1) } # load from fixture to get services assoc
    let(:service_name) {app.services.first.name}
    let(:client) { double(:client, destroy: service_name) }

    before do
      PanamaxAgent.stub(fleet_client: client)
      PanamaxAgent::Fleet::Client.any_instance.stub(:destroy).and_return true
    end

    it 'deletes the app' do
      delete :destroy, { id: app.id, format: :json }
      expect(App.where(id: app.id).first).to be_nil
    end

    it 'destroys the app services' do
      delete :destroy, { id: app.id, format: :json }
      expect(Service.where(app_id: app.id)).to be_empty
    end

    it "returns no content in response body" do
      delete :destroy, { id: app.id, format: :json }
      expect(response.body).to be_empty
    end

  end

end