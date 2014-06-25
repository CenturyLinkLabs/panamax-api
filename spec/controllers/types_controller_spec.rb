require 'spec_helper'

describe TypesController do

  describe 'GET #index' do
    it 'returns all the types as JSON' do
      get :index, format: :json
      flattened_results = JSON.parse(response.body).map { |t| t['name'] }
      expect(flattened_results).to eq PanamaxApi::TYPES
      expect(response.body).to eq [
        { 'name' => 'Default' },
        { 'name' => 'Wordpress' },
        { 'name' => 'Tomcat' },
        { 'name' => 'Rails' },
        { 'name' => 'NodeJS' },
        { 'name' => 'MySQL' },
        { 'name' => 'Magento' },
        { 'name' => 'LAMP' },
        { 'name' => 'Java' },
        { 'name' => 'HuBot' },
        { 'name' => 'Drupal' },
        { 'name' => 'Django' },
        { 'name' => 'Apache' },
        { 'name' => 'Ubuntu' }
      ].to_json
    end
  end

end
