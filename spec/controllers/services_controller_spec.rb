require 'spec_helper'

describe ServicesController do

  describe 'GET index' do

    let(:app){ App.first }

    it 'returns an array' do
      get :index, {app_id: app.id, format: :json}
      expect(JSON.parse(response.body)).to be_an Array
    end

    it "returns a specific app" do
      get :show, { app_id: app.id, id: Service.first.id, format: :json }
      expect(response.body).to eq (ServiceSerializer.new(Service.first)).to_json
    end

    it 'service representations have an app representation in the app attribute' do
      get :show, { id: Service.first.id, app_id: app.id, format: :json }
      expect(JSON.parse(response.body)).to have_key('app')
      expect(JSON.parse(response.body)['app']).to eq JSON.parse(AppLiteSerializer.new(app).to_json)
    end

  end

end