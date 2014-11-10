require 'spec_helper'

describe KeywordsController do

  describe 'GET #index' do
    fixtures :templates

    it 'returns all the keywords as JSON' do
      expected = [
        { keyword: 'blah', count: 1 },
        { keyword: 'wordpress', count: 1 },
        { keyword: 'wp', count: 1 }
      ]
      get :index, format: :json
      expect(response.body).to eq expected.to_json
    end
  end

end
