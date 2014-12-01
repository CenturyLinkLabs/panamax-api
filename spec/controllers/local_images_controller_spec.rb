require 'spec_helper'

describe LocalImagesController do

  describe '#index' do

    let(:images) { [LocalImage.new(id: 'foo'), LocalImage.new(id: 'bar')] }

    before do
      allow(LocalImage).to receive(:all).and_return(images)
    end

    it 'returns a list of images' do
      get :index, format: :json
      expect(response.body).to eq images.to_json
    end

    it 'without a limit parameter returns all images' do
      get :index, format: :json
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it 'allows a limit parameter to limit the number of images returned in the response' do
      get :index, limit: 1, format: :json
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it 'includes a Total-Count header with the image count' do
      get :index, limit: 1, format: :json
      expect(response.headers['Total-Count']).to eq LocalImage.all.size
    end

    it 'returns an HTTP 200 status code' do
      get :index, format: :json
      expect(response.status).to eq 200
    end
  end

  describe '#show' do

    let(:image) { LocalImage.new(id: 'ab12', tags: ['a/b:latest', 'a/b:1.0']) }

    context 'when image is found' do

      before do
        allow(LocalImage).to receive(:find_by_id_or_name).and_return(image)
      end

      it 'queries for the local image' do
        expect(LocalImage).to receive(:find_by_id_or_name).with(image.id)
        get :show, id: image.id, format: :json
      end

      it 'returns the image' do
        get :show, id: image.id, format: :json
        expect(response.body).to eq image.to_json
      end
    end

    context 'when image is not found' do

      before do
        allow(LocalImage).to receive(:find_by_id_or_name).and_return(nil)
      end

      it 'returns an HTTP 404 status code' do
        get :show, id: 'a1b2c3', format: :json
        expect(response.status).to eq 404
      end
    end
  end

  describe '#destroy' do

    let(:id) { 'abc123' }

    before do
      allow(LocalImage).to receive(:destroy).and_return(true)
    end

    it 'destroys the image' do
      expect(LocalImage).to receive(:destroy)
      delete :destroy, id: id, format: :json
    end

    it 'returns an HTTP 204 status code' do
      delete :destroy, id: id, format: :json
      expect(response.status).to eq 204
    end

    context 'when a Conflict error is raised' do

      before do
        allow(LocalImage).to receive(:destroy).and_raise(Excon::Errors::Conflict, 'oops')
      end

      it 'returns an error' do
        delete :destroy, id: id, format: :json
        expect(response.body).to eq({ message: I18n.t(:docker_rmi_error) }.to_json)
      end

      it 'returns a 500 status code' do
        delete :destroy, id: id, format: :json
        expect(response.status).to eq 500
      end
    end
  end
end
