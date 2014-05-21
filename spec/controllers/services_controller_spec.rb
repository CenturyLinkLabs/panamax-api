require 'spec_helper'

describe ServicesController do
  let(:app){ App.first }

  describe '#index' do

    it 'returns an array' do
      get :index, {app_id: app.id, format: :json}
      expect(JSON.parse(response.body)).to be_an Array
    end

  end

  describe '#show' do

    it "returns a specific app" do
      get :show, { app_id: app.id, id: Service.first.id, format: :json }
      expect(response.body).to eq (ServiceSerializer.new(Service.first)).to_json
    end

    it 'returns service representations with an app representation in the app attribute' do
      get :show, { id: Service.first.id, app_id: app.id, format: :json }
      expect(JSON.parse(response.body)).to have_key('app')
      expect(JSON.parse(response.body)['app']).to eq JSON.parse(AppLiteSerializer.new(app).to_json)
    end

  end

  describe '#update' do

    let(:dummy_app) { double(:app) }
    let(:dummy_service) { double(:service) }
    let(:params) do
      {
        name: 'servicename',
        description: 'servicedescription',
        ports: [{ host_port: '80', container_port: '80', proto: 'tcp'}],
        expose: ['80', '443'],
        environment: { 'SOME_KEY' => 'some_value'},
        volumes: [{ host_path: '/tmp/foo', container_path: '/tmp/bar' }],
      }
    end

    before do
      App.stub(:find).and_return(dummy_app)
      dummy_app.stub_chain(:services, :find).and_return(dummy_service)
      dummy_service.stub(:update_with_relationships).and_return(true)
      dummy_app.stub(:restart)
    end

    it 'updates attributes on the service' do
      expect(dummy_service).to receive(:update_with_relationships).with(hash_including(params))

      put :update, params.merge(
        app_id: '1',
        id: '2',
        format: :json
      )
    end

    context 'when the service update succeeds' do

      it 'restarts the service' do
        expect(dummy_app).to receive(:restart)

        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )
      end
    end

    context 'when the service update fails' do

      before do
        dummy_service.stub(:update_with_relationships).and_return(false)
      end

      it 'restarts the app' do
        expect(dummy_app).to_not receive(:restart)

        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )
      end
    end

    it 'returns an empty response body' do
      put :update, params.merge(
        app_id: '1',
        id: '2',
        format: :json
      )

      expect(response.body).to be_empty
    end
  end

  describe '#destroy' do
    let(:dummy_app) { double(:app) }
    let(:dummy_service) { double(:service) }

    before do
      App.stub(:find).and_return(dummy_app)
      dummy_app.stub_chain(:services, :find).and_return(dummy_service)
      dummy_service.stub(:destroy).and_return(dummy_service)
    end

    it 'calls destroy on the service' do
      delete :destroy, { app_id: '1', id: '2', format: :json }
      expect(dummy_service).to have_received(:destroy)
    end

    it 'returns an empty response body' do
      delete :destroy, { app_id: '1', id: '2', format: :json }
      expect(response.body).to be_empty
    end

    it 'returns an response code 204' do
      delete :destroy, { app_id: '1', id: '2', format: :json }
      expect(response.status).to eq 204
    end

  end

  describe '#journal' do

    it 'returns the service journal' do
      get :journal, { app_id: app.id, id: Service.first.id, format: :json }
      expect(response.body).to eq fixture_data('journal')
    end
  end

  describe '#create' do
    let(:some_app) { double(:app) }
    let(:new_service) do
      {
          id: 1,
          name: 'foo_bar',
          description: 'my foo service',
          from: 'some image',
          links:[],
          ports: [],
          expose: [],
          volumes: [],
          environment: { 'SOME_KEY' => ''},
          app: { id: 1},
          categories: [{ id: 1, id: 2}]
      }
    end

    let(:params) do
      {
          name: 'foo_bar',
          description: 'my foo service',
          from: 'some image',
          :categories => [{ id: 1, id: 2}],
          ports: [{host_interface: '', host_port: '', container_port: '', proto: ''}],
          expose: [''],
          links:[],
          volumes: [{host_path: '', container_path: ''}],
          environment: { 'SOME_KEY' => ''}
      }
    end

    before do
      App.stub(:find).and_return(some_app)
      some_app.stub(:add_service).and_return(new_service)
      some_app.stub(:restart).with(no_args())
    end

    it 'creates a service with category' do
      expect(some_app).to receive(:add_service).with(params.stringify_keys!).and_return(new_service)
      post :create, params.merge(
        app_id: '1',
        format: :json)
    end

    it 'creates a service without category' do
      params.delete(:categories)
      some_app.stub(:restart).with(no_args())
      expect(some_app).to receive(:add_service).with(params.stringify_keys!).and_return(new_service)
      post :create, params.merge(
          app_id: '1',
          format: :json)
    end

    it 'creates a service and then restarts the app' do
      expect(some_app).to receive(:add_service).with(params.stringify_keys!).and_return(new_service).ordered
      expect(some_app).to receive(:restart).with(no_args()).ordered
      post :create, params.merge(
          app_id: '1',
          format: :json)
    end

    it 'returns the jsonified service in response' do
      post :create, params.merge(
          app_id: '1',
          format: :json)
      expect(response.body).to eq(new_service.to_json)
    end

  end

end
