require 'spec_helper'

describe SearchController do

  describe 'GET index' do

    it 'includes the original query in the response' do
      Docker.stub(:connection).and_return(double("Docker::Connection", get: nil))

      get :index, { q: "fake", format: 'json' }
      expect(JSON.parse(response.body)).to include({"q"=>'fake'})
    end

    context 'searching the docker index' do
      let(:query) { 'fake' }

      let(:fake_image_data) do
        [{
             "description"=>"",
             "is_official"=>false,
             "is_trusted"=>true,
             "name"=>"fake/tomcat7",
             "star_count"=>1,
             "id"=>"fake/tomcat7"
         }]
      end

      let(:connection) do
        conn = Docker::Connection.new('unix:///var/run/docker.sock', {})
        conn.stub(:get).and_return(fake_image_data.to_json)
        conn
      end

      let(:image) { Docker::Image.new(connection, fake_image_data.first) }

      before { Docker.stub(:connection).and_return(connection) }

      it 'queries the docker index with the q argument' do
        expect(Docker::Image).to receive(:search).with({ term: query })
        get :index, { q: "#{query}", format: 'json' }
      end

      it 'response includes Docker index image data' do
        get :index, { q: "#{ query}", format: 'json' }
        expect(response.body).to include(image.to_json)
      end

    end

    context 'searching for local images' do
      let(:query) { 'fake' }

      let(:fake_image_data) do
        [{
            "RepoTags" => [
            "fake:latest"
            ],
            "Id" =>"8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c",
            "Created" =>1365714795,
            "Size" =>131506275,
            "VirtualSize" =>131506275
         }]
      end

      let(:connection) do
        conn = Docker::Connection.new('unix:///var/run/docker.sock', {})
        conn.stub(:get).and_return(fake_image_data.to_json)
        conn
      end

      let(:image){Docker::Image.new(connection, fake_image_data.first)}

      before { Docker.stub(:connection).and_return(connection) }

      it 'retrieves all local images through the Docker remote api' do
        expect(Docker::Image).to receive(:all).and_return([])
        get :index, { q: "#{ query}", format: 'json' }
      end

      it 'response includes local image data' do
        Docker::Image.stub(:all).and_return([image])
        get :index, { q: "#{query}", format: 'json' }
        expect(response.body).to include(image.to_json)
      end

    end



    context 'recommending a template' do
      let(:query){ 'wordpress' }
      before do
        Docker::Image.stub(:search).and_return(nil)
        Docker::Image.stub(:all).and_return([])
      end
      it 'returns the first recommended template with a name matching the query' do
        get :index, {q: "#{query}", format: 'json'}
        expect(response.body).to include(Template.where(name: 'wordpress').first.to_json)
      end
    end
  end

end