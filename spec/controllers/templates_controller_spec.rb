require 'spec_helper'

describe TemplatesController do

  describe 'GET templates' do

    it "returns the list of templates" do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
      expect(response.body).to include(TemplateSerializer.new(Template.first).to_json)
    end

    it "returns a specific template" do
      get :show, { id: Template.first.id, format: :json }
      expect(response.body).to eq TemplateSerializer.new(Template.first).to_json
    end

  end

end