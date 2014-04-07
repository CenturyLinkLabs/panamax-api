require 'spec_helper'

describe AppsController do

  describe 'GET index' do

    it 'returns an array' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
    end

    it "returns a specific app" do
      get :show, { id: App.first.id, format: :json }
      expect(response.body).to eq (AppSerializer.new(App.first)).to_json
    end

    it 'app representations have an array of services in the services attribute' do
      get :show, { id: App.first.id, format: :json }
      expect(JSON.parse(response.body)).to have_key('services')
      expect(JSON.parse(response.body)['services']).to be_an Array
    end

  end

end