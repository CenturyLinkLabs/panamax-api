require 'spec_helper'

describe ServicesController do
  let(:image_status) do
    double(:image_status,
           info: {
             'Config' => {
               'ExposedPorts' => {'3000/tcp' => {} }
             }
           })
  end

  before do
    allow(Docker::Image).to receive(:get).and_return(image_status)

    # Prevent any API calls for retrieving service status
    allow_any_instance_of(Service).to receive(:service_state).and_return({})
  end

  describe '#index' do
    fixtures :apps
    let(:app) { App.first }

    it 'returns an array' do
      get :index, app_id: app.id, format: :json
      expect(JSON.parse(response.body)).to be_an Array
    end

  end

  describe '#show' do
    fixtures :apps, :services
    let(:app) { App.first }

    it 'returns a specific app' do
      get :show, app_id: app.id, id: Service.first.id, format: :json
      expect(response.body).to eq ServiceSerializer.new(Service.first).to_json
    end

    it 'returns service representations with an app representation in the app attribute' do
      get :show, id: Service.first.id, app_id: app.id, format: :json
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
        ports: [{ host_port: '80', container_port: '80', proto: 'tcp' }],
        expose: %w(80 443),
        environment: [{ 'variable' => 'SOME_KEY', 'value' => 'some_value' }],
        volumes: [{ host_path: '/tmp/foo', container_path: '/tmp/bar' }],
        command: 'rails s'
      }
    end

    before do
      allow(App).to receive(:find).and_return(dummy_app)
      allow(dummy_app).to receive_message_chain(:services, :find).and_return(dummy_service)
      allow(dummy_service).to receive(:update_with_relationships).and_return(true)
      allow(dummy_app).to receive(:restart)
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

      it 'restarts the app' do
        expect(dummy_app).to receive(:restart)

        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )
      end

      it 'bypass restart when restart is false' do
        expect(dummy_app).to_not receive(:restart)

        put :update, params.merge(
          app_id: '1',
          id: '2',
          restart: 'false',
          format: :json
        )
      end

      it 'returns a successful status' do
        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )

        expect(response.status).to eq 204
      end
    end

    context 'when the service update fails' do

      before do
        allow(dummy_service).to receive(:update_with_relationships).and_return(false)
        allow(dummy_service).to receive(:errors).and_return(['some errors'])
      end

      it 'does not restart the app' do
        expect(dummy_app).to_not receive(:restart)

        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )
      end

      it 'returns a unprocessable entity status' do
        put :update, params.merge(
          app_id: '1',
          id: '2',
          format: :json
        )

        expect(response.status).to eq 422
      end
    end

    context 'when restart raises a PanamaxAgent::ConnectionError' do

      before do
        allow(dummy_app).to receive(:restart).and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns the fleet error message' do
        put :update, params.merge(app_id: '1', id: '2', format: :json)

        expect(response.body).to eq(
          { message: I18n.t(:fleet_connection_error) }.to_json)
      end

      it 'returns a 500 status code' do
        put :update, params.merge(app_id: '1', id: '2', format: :json)
        expect(response.status).to eq 500
      end
    end
  end

  describe '#destroy' do
    let(:dummy_app) { double(:app) }
    let(:dummy_service) { double(:service) }

    before do
      allow(App).to receive(:find).and_return(dummy_app)
      allow(dummy_app).to receive_message_chain(:services, :find).and_return(dummy_service)
      allow(dummy_service).to receive(:destroy).and_return(dummy_service)
    end

    it 'calls destroy on the service' do
      delete :destroy, app_id: '1', id: '2', format: :json
      expect(dummy_service).to have_received(:destroy)
    end

    it 'returns an empty response body' do
      delete :destroy, app_id: '1', id: '2', format: :json
      expect(response.body).to be_empty
    end

    it 'returns an response code 204' do
      delete :destroy, app_id: '1', id: '2', format: :json
      expect(response.status).to eq 204
    end

  end

  describe '#journal' do
    fixtures :apps, :services
    let(:app) { App.first }

    it 'returns the service journal' do
      get :journal, app_id: app.id, id: Service.first.id, format: :json
      expect(response.body).to eq fixture_data('journal')
    end

    context 'when the journal API is not responding' do

      before do
        allow_any_instance_of(Service).to receive(:journal)
          .and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns an HTTP 500 status code' do
        get :journal, app_id: app.id, id: Service.first.id, format: :json
        expect(response.status).to eq 500
      end

      it 'returns the journal error message' do
        get :journal, app_id: app.id, id: Service.first.id, format: :json

        expect(response.body).to eq(
          { message: I18n.t(:journal_connection_error) }.to_json)
      end
    end
  end

  describe '#create' do
    fixtures :apps, :services
    let(:app) { apps(:app1) }

    let(:params) do
      {
        name: 'foo_bar',
        description: 'my foo service',
        from: 'some image'
      }
    end

    before do
      allow_any_instance_of(App).to receive(:restart)
    end

    it 'adds a new service' do
      expect do
        post :create, params.merge(app_id: app, format: :json)
      end.to change(Service, :count).by(1)

    end

    it 'initializes the new service with the specified params' do
      post :create, params.merge(app_id: app, format: :json)

      expect(Service.last.name).to eq params[:name]
      expect(Service.last.description).to eq params[:description]
    end

    it 'restarts the app' do
      expect_any_instance_of(App).to receive(:restart)
      post :create, params.merge(app_id: app, format: :json)
    end

    it 'returns the service' do
      post :create, params.merge(app_id: app, format: :json)
      expect(response.body).to eq ServiceSerializer.new(Service.last).to_json
    end

    it 'returns a 201 status code' do
      post :create, params.merge(app_id: app, format: :json)
      expect(response.status).to eq 201
    end

    context 'when restart raises a PanamaxAgent::ConnectionError' do

      before do
        allow_any_instance_of(App).to receive(:restart).and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns the fleet error message' do
        post :create, params.merge(app_id: app, format: :json)

        expect(response.body).to eq(
          { message: I18n.t(:fleet_connection_error) }.to_json)
      end

      it 'returns a 500 status code' do
        post :create, params.merge(app_id: app, format: :json)
        expect(response.status).to eq 500
      end
    end
  end

end
