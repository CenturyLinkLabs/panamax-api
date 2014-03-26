require 'spec_helper'

describe SearchController do

  describe 'GET index' do

    let(:query) { 'some, search, query' }
    let(:fake_image_data) { [{fake_image_data: 'bla'}] }

    it 'queries the docker index with the q argument' do
      expect(Docker::Image).to receive(:search).with({ term: query })
      get :index, {q: "#{query}", format: 'json'}
    end

    it 'returns an array of image data' do
      Docker::Image.stub(:search).and_return(fake_image_data)
      get :index, {q: "#{query}", format: 'json'}

      expect(response.body).to eq({remote_images: fake_image_data}.to_json)
    end
  end

end