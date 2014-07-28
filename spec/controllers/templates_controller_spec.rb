require 'spec_helper'

describe TemplatesController do

  describe 'GET templates' do

    it 'returns the list of templates' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
      expect(response.body).to include(TemplateSerializer.new(Template.first).to_json)
    end

    it 'returns a specific template' do
      get :show, id: Template.first.id, format: :json
      expect(response.body).to eq TemplateSerializer.new(Template.first).to_json
    end

  end

  describe 'POST templates' do
    let(:template_params) do
      HashWithIndifferentAccess.new(
        name: 'new-template',
        description: 'some template',
        keywords: 'foo,baz,bar',
        type: 'wordpress',
        documentation: '---\n\nBlah\n\n',
        app_id: '1',
        images: [
          {
            'category' => 'Web Tier',
            'name' => 'MyWebApp',
            'source' => 'centurylinklabs/buildstepper:latest',
            'description' => 'My Web App running in-container',
            'type' => 'Default',
            'expose' =>  ['80'],
            'ports' => [{ 'container_port' => '80' }],
            'links' =>  [{ 'service_id'  =>  '3', 'alias'  =>  'foo' }],
            'environment' =>
            [
              { 'variable' => 'PORT', 'value' => '80' },
              { 'variable' => 'GIT_REPO', 'value' => 'https://github.com/fermayo/hello-world-php.git' }
            ],
            'volumes' =>  [],
            'command' => '/start web'
          }
        ]
      )
    end

    before { TemplateBuilder.stub(:create).and_return templates(:wordpress) }

    it 'calls out to the TemplateBuilder with permitted parameters' do
      expect(TemplateBuilder).to receive(:create).with(template_params)
      post :create, template_params.merge(format: :json)
    end

    it 'responds with a json representation of the template' do
      post :create, template_params.merge(format: :json)
      expect(response.body).to eq(TemplateFileSerializer.new(templates(:wordpress)).to_json)
    end

    it 'returns 422 if the template could not be persisted' do
      TemplateBuilder.stub(:create).and_return templates(:wordpress).tap { |t| t.errors[:base] = 'bad' }
      post :create, template_params.merge(format: :json)
      expect(response.status).to eq 422
    end

    it 'returns 500 if an exception occured during template creation' do
      TemplateBuilder.stub(:create).and_raise 'boom'
      post :create, template_params.merge(format: :json)
      expect(response.status).to eq 500
    end

  end

  describe '#destroy' do
    let(:template) { templates(:another) }

    it 'removes the template' do
      expect do
        delete :destroy, id: template.id, format: :json
      end.to change { Template.count }.by(-1)
    end

    it 'responds a 204' do
      delete :destroy, id: template.id, format: :json
      expect(response.status).to eq 204
    end
  end

  describe '#save' do
    let(:template) { Template.first }
    let(:save_response) do
      { content:
        {
          html_url: 'https://github.com/bob/repo/blob/master/somefile.pmx'
        }
      }
    end
    let(:params) do
      {
        repo: 'bob/repo',
        file_name: 'somefile'
      }
    end

    before do
      Template.any_instance.stub(:save_to_repo).with(hash_including(params)).and_return(save_response)
    end

    it 'saves a template to a repo' do
      expect_any_instance_of(Template).to receive(:save_to_repo).with(hash_including(params))

      post :save, params.merge(
          id: template.id,
          format: :json
      )
    end

    it 'returns a no content status' do
      post :save, params.merge(
          id: template.id,
          format: :json
      )
      expect(response.status).to eq 204
    end

    it 'returns the template file location in the header' do
      post :save, params.merge(
          id: template.id,
          format: :json
      )
      expect(response.header['Location']).to eq 'https://github.com/bob/repo/blob/master/somefile.pmx'
    end

    context 'when the template save fails' do

      before do
        Template.any_instance.stub(:save_to_repo).with(hash_including(params)).and_raise('error')
      end

      it 'returns an internal_server_error status' do
        post :save, params.merge(
            id: template.id,
            format: :json
        )
        expect(response.status).to eq 500
      end
    end
  end

end
