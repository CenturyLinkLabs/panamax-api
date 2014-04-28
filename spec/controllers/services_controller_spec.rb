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

  describe '#journal' do

    it 'returns the service journal' do
      get :journal, { app_id: app.id, id: Service.first.id, format: :json }
      expect(response.body).to eq fixture_data('journal')
    end
  end

end
