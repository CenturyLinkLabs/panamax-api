require 'spec_helper'

describe AppsController do
  fixtures :apps

  describe '#index' do

    it 'returns an array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
    end

    it 'without a limit parameter returns all apps' do
      get :index, format: :json
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it 'allows a limit parameter to limit the number of apps returned in the response' do
      get :index, limit: 1, format: :json
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it 'includes a Total-Count header with the App count' do
      get :index, limit: 1, format: :json
      expect(response.headers['Total-Count']).to eq App.count
    end

  end

  describe '#show' do
    it 'returns a specific app' do
      get :show, id: App.first.id, format: :json
      expect(response.body).to eq AppSerializer.new(App.first).to_json
    end
  end

  describe '#update' do
    let(:app) { apps(:app1) }

    let(:params) { { name: 'My App', id: app, format: :json, from: 'some template', documentation: 'blah' } }

    it 'changes attributes' do
      put :update, params

      app.reload
      expect(app.name).to eql params[:name]
      expect(app.from).to eql params[:from]
      expect(app.documentation).to eql params[:documentation]
    end

    it 'returns a 204 status code' do
      put :update, params
      expect(response.status).to eq 204
    end
  end

  describe '#create' do
    fixtures :templates
    let(:template) { templates(:wordpress) }

    before do
      allow_any_instance_of(App).to receive(:run)
    end

    it 'creates a new app' do
      expect do
        post :create, template_id: template.id, format: :json
      end.to change(App, :count).by(1)
    end

    it 'runs the app' do
      expect_any_instance_of(App).to receive(:run)
      post :create, template_id: template.id, format: :json
    end

    it 'logs a KissMetrcis event' do
      expect(subject).to receive(:log_kiss_event)
        .with('run-template', template_name: template.name)
      post :create, template_id: template.id, format: :json
    end

    it 'returns a new app' do
      post :create, template_id: template.id, format: :json
      expect(response.body).to eq AppSerializer.new(App.last).to_json
    end

    it 'returns a 201 status code' do
      post :create, template_id: template.id, format: :json
      expect(response.status).to eq 201
    end

    context 'when the app is invalid' do

      before do
        template.name = nil
      end

      it 'does not create an app' do
        expect do
          post :create, format: :json
        end.to change(App, :count).by(0)
      end

      it 'does not run the app' do
        expect_any_instance_of(App).to_not receive(:run)
        post :create, format: :json
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        post :create, format: :json
      end
    end

    context 'when an error occurs' do

      before do
        allow_any_instance_of(App).to receive(:run).and_raise('boom')
      end

      it 'does not create an app' do
        expect do
          post :create, template_id: template.id, format: :json
        end.to change(App, :count).by(0)
      end

      it 'returns an error' do
        post :create, template_id: template.id, format: :json
        expect(response.body).to eq({ message: 'boom' }.to_json)
      end

      it 'returns a 500 status code' do
        post :create, template_id: template.id, format: :json
        expect(response.status).to eq 500
      end
    end

    context 'when a PanamaxAgent::ConnectionError error occurs' do

      before do
        allow_any_instance_of(App).to receive(:run).and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'does not create an app' do
        expect do
          post :create, template_id: template.id, format: :json
        end.to change(App, :count).by(0)
      end

      it 'returns the fleet error message' do
        post :create, template_id: template.id, format: :json
        expect(response.body).to eq(
          { message: I18n.t(:fleet_connection_error) }.to_json)
      end

      it 'returns a 500 status code' do
        post :create, template_id: template.id, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe '#destroy' do
    let(:app) { apps(:app1) } # load from fixture to get services assoc
    let(:service_name) { app.services.first.name }

    before do
      allow_any_instance_of(ServiceManager).to receive(:destroy).and_return(true)
    end

    it 'deletes the app' do
      delete :destroy, id: app.id, format: :json
      expect(App.where(id: app.id).first).to be_nil
    end

    it 'destroys the app services' do
      delete :destroy, id: app.id, format: :json
      expect(Service.where(app_id: app.id)).to be_empty
    end

    it 'returns no content in response body' do
      delete :destroy, id: app.id, format: :json
      expect(response.body).to be_empty
    end
  end

  describe '#journal' do

    let(:app) { apps(:app1) } # load from fixture to get services assoc

    it 'returns the service journal' do
      get :journal, id: app.id, format: :json
      expect(response.body).to eql fixture_data('journal')
    end

    context 'when the journal API is not responding' do

      before do
        allow_any_instance_of(App).to receive(:journal)
          .and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns an HTTP 500 status code' do
        get :journal, id: app.id, format: :json
        expect(response.status).to eq 500
      end

      it 'returns the journal error message' do
        get :journal, id: app.id, format: :json

        expect(response.body).to eq(
          { message: I18n.t(:journal_connection_error) }.to_json)
      end
    end
  end

  describe '#rebuild' do

    let(:app) { App.first }

    before do
      allow(App).to receive(:find).and_return(app)
      allow(app).to receive(:restart)
    end

    it 'invokes restart on the app object' do
      expect(app).to receive(:restart)
      put :rebuild, id: app.id, format: :json
    end

    it 'returns a no content status' do
      put :rebuild, id: app.id, format: :json
      expect(response.status).to eq(204)
    end

    context 'when a PanamaxAgent::ConnectionError error occurs' do

      before do
        allow(app).to receive(:restart).and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns the fleet error message' do
        put :rebuild, id: app.id, format: :json
        expect(response.body).to eq(
          { message: I18n.t(:fleet_connection_error) }.to_json)
      end

      it 'returns a 500 status code' do
        put :rebuild, id: app.id, format: :json
        expect(response.status).to eq 500
      end
    end

  end

  describe '#template' do

    let(:app) { App.first }
    let(:template_params) do
      {
        'name' => 'foo',
        'description' => 'foobar',
        'keywords' => 'foo, bar',
        'authors' => 'foo',
        'type' => 'foo',
        'documentation' => 'foo docs'
      }
    end
    let(:template) { Template.new(name: 'Template1',
                                  description: 'my template',
                                  keywords: 'foo, bar',
                                  documentation: "# Title\r\nSome *markdown*") }

    before do
      allow(TemplateBuilder).to receive(:create).and_return(template)
    end

    it 'invokes the template builder' do
      expect(TemplateBuilder).to receive(:create).with(template_params.merge('app_id' => app.id.to_s), false)
      post :template, template_params.merge('id' => app.id), format: :json
    end

    it 'returns a serialized version of the template' do
      expected_json_str = {template: TemplateFileSerializer.new(template).to_yaml}

      post :template, template_params.merge(id: app.id), format: :json
      expect(response.body).to eq(expected_json_str.to_json)
    end

    it 'returns a success status' do
      post :template, template_params.merge(id: app.id), format: :json
      expect(response.status).to eq(200)
    end

  end

  describe '#compose_yml' do
    fixtures :services

    let(:app) { App.first }
    let(:converter) { double('converter', to_compose_yaml: '---\n') }

    before do
      allow(Converters::AppConverter).to receive(:new).with(app).and_return(converter)
    end

    it 'invokes the app converter' do
      expect(Converters::AppConverter).to receive(:new).with(app)
      get :compose_yml, id: app.id
    end

    it 'returns the textual representation of the compose yaml version of the app' do
      get :compose_yml, id: app.id, format: :text
      expect(response.body).to eq('---\n')
    end

    it 'returns the yaml representation of the compose yaml version of the app' do
      get :compose_yml, id: app.id, format: :yaml
      expect(response.body).to eq('---\n')
    end

    it 'returns the json representation of the compose yaml version of the app' do
      get :compose_yml, id: app.id, format: :json
      expect(response.body).to eq('{"compose_yaml":"---\\\\n"}')
    end
  end

  describe '#compose_gist' do
    fixtures :services

    let(:app) { App.first }
    let(:converter_response) do
      {
        html_url: 'html',
        files: { 'docker-compose.yml' => { raw_url: 'raw' } }
      }
    end
    let(:converter) { double('converter', to_compose_gist: converter_response) }
    let(:expected_response) { { links: { gist: { href: 'html', raw_url: 'raw' } } } }

    before do
      allow(Converters::AppConverter).to receive(:new).with(app).and_return(converter)
    end

    it 'invokes the app converter' do
      expect(Converters::AppConverter).to receive(:new).with(app)
      post :compose_gist, id: app.id, format: :json
    end

    it 'returns a created status' do
      post :compose_gist, id: app.id, format: :json
      expect(response.status).to eq(201)
    end

    it 'returns the gist URIs' do
      post :compose_gist, id: app.id, format: :json
      expect(response.body).to eq expected_response.to_json
    end
  end
end
