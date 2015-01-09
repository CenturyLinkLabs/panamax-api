require 'spec_helper'

describe JobTemplatesController do
  fixtures :job_templates

  describe 'GET job_templates' do
    it 'returns an array of job templates' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
      expect(response.body).to include(JobTemplateSerializer.new(JobTemplate.first).to_json)
    end

    it 'returns a specific template' do
      get :show, id: JobTemplate.first.id, format: :json
      expect(response.body).to eq JobTemplateSerializer.new(JobTemplate.first).to_json
    end
  end

end
