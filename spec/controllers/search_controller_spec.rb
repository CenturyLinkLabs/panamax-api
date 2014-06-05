require 'spec_helper'

describe SearchController do

  describe 'GET index' do

    let(:query) { 'fake' }

    let(:remote_image) { Image.new }

    let(:local_image) { Image.new }

    before do
      Image.stub(:search_remote_index).and_return([remote_image])
      Image.stub(:local_with_repo_like).and_return([local_image])
    end

    context 'when searching for templates only' do
      let(:query) { 'wordpress' }

      it 'only returns templates' do
        get :index, q: "#{query}", type: 'template', format: 'json'
        parsed_results = JSON.parse(response.body)
        expect(parsed_results.keys).to match_array %w(templates q)
      end

      it 'does not search remote images' do
        expect(Image).to_not receive(:search_remote_index)
        get :index, q: "#{query}", type: 'template', format: 'json'
      end

      it 'does not search local images' do
        expect(Image).to_not receive(:local_with_repo_like)
        get :index, q: "#{query}", type: 'template', format: 'json'
      end
    end

    context 'when searching for local images only' do
      let(:query) { 'wordpress' }

      it 'only returns templates' do
        get :index, q: "#{query}", type: 'local_image', format: 'json'
        parsed_results = JSON.parse(response.body)
        expect(parsed_results.keys).to match_array %w(local_images q)
      end

      it 'does not search remote images' do
        expect(Image).to_not receive(:search_remote_index)
        get :index, q: "#{query}", type: 'local_image', format: 'json'
      end

      it 'does not search templates' do
        expect(Template).to_not receive(:recommended)
        get :index, q: "#{query}", type: 'local_image', format: 'json'
      end
    end

    context 'when searching for remote images only' do
      let(:query) { 'wordpress' }

      it 'only returns templates' do
        get :index, q: "#{query}", type: 'remote_image', format: 'json'
        parsed_results = JSON.parse(response.body)
        expect(parsed_results.keys).to match_array %w(remote_images q)
      end

      it 'does not search remote images' do
        expect(Image).to_not receive(:local_with_repo_like)
        get :index, q: "#{query}", type: 'remote_image', format: 'json'
      end

      it 'does not search templates' do
        expect(Template).to_not receive(:recommended)
        get :index, q: "#{query}", type: 'remote_image', format: 'json'
      end
    end

    context 'when type is not supplied' do
      it 'passes the query to the Image when searching the remote index' do
        expect(Image).to receive(:search_remote_index).with(term: query)
        get :index, q: "#{query}", format: 'json'
      end

      it 'queries local images when searching' do
        expect(Image).to receive(:local_with_repo_like).with(query)
        get :index, q: "#{query}", format: 'json'
      end

      it 'returns local images with the query term in the name' do
        get :index, q: "#{query}", format: 'json'
        expect(response.body).to include(local_image.to_json)
      end

      it 'returns remote images matching the query term' do
        get :index, q: "#{query}", format: 'json'
        expect(response.body).to include(remote_image.to_json)
      end

      it 'includes the original query in the response' do
        get :index, q: 'fake', format: 'json'
        expect(JSON.parse(response.body)).to include('q' => 'fake')
      end

      context 'recommending a template' do
        let(:query) { 'wordpress' }

        before do
          Docker::Image.stub(:search).and_return(nil)
          Docker::Image.stub(:all).and_return([])
        end

        it 'returns the recommended templates with a name matching the query' do
          get :index, q: "#{query}", format: 'json'
          parsed_results = JSON.parse(response.body)
          expect(parsed_results['templates']).to be_an Array
          expect(response.body).to include(TemplateSerializer.new(templates(:wordpress)).to_json)
        end
      end
    end
  end

end
