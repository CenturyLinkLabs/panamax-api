require 'spec_helper'

describe SearchController do

  describe 'GET index' do

    let(:query) { 'some, search, query' }
    let(:fake_image_data) { [{'fake_image_data' =>'bla', 'Id' => "fake"}] }
    let(:connection) do
      conn = Docker::Connection.new('unix:///var/run/docker.sock', {})
      conn.stub(get: (fake_image_data.to_json))
      conn
    end

    before { Docker.stub(:connection).and_return(connection) }

    it 'queries the docker index with the q argument' do
      expect(Docker::Image).to receive(:search).with({ term: query })
      get :index, { q: "#{query}", format: 'json' }
    end

    it 'retrieves all local images through the Docker remote api' do
      expect(Docker::Image).to receive(:all)
      get :index, { q: "#{ query}", format: 'json' }
    end

    context 'returns an array of image data' do
      it 'includes Docker index image data' do
        Docker::Image.stub(:search).and_return(fake_image_data)
        get :index, { q: "#{ query}", format: 'json' }

        expect(JSON.parse(response.body)).to include({'remote_images' => fake_image_data})
      end

      it 'includes local image data' do
        Docker::Image.stub(:all).and_return(fake_image_data)
        get :index, { q: "#{query}", format: 'json' }
        expect(JSON.parse(response.body)).to include({'local_images' => fake_image_data})
      end
    end

  end

end