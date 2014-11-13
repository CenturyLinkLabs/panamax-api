require 'spec_helper'

describe RemoteDeploymentsController do
  let(:deployment_target) { double(:target) }
  let(:deployment_service) { double(:deployment_service) }
  let(:deployment) { RemoteDeployment.new(id: 123) }

  before do
    DeploymentTarget.stub(:find).with('44').and_return(deployment_target)
    deployment_target.
      stub(:new_agent_service).
      with(DeploymentService).
      and_return(deployment_service)
  end

  describe 'GET #index' do

    let(:deployments) do
      [
        RemoteDeployment.new(id: 234),
        RemoteDeployment.new(id: 456)
      ]
    end

    before do
      deployment_service.stub(:all).and_return(deployments)
    end

    it 'returns a list of deployments' do
      get :index, deployment_target_id: 44, format: :json
      expect(response.body).to eq deployments.to_json
    end

    it 'returns a HTTP 200 status code' do
      get :index, deployment_target_id: 44, format: :json
      expect(response.status).to eq 200
    end
  end

  describe 'GET #show' do

    before do
      deployment_service.stub(:find)
    end

    context 'when the resource exists' do

      before do
        deployment_service.stub(:find).with('22').and_return(deployment)
      end

      it 'returns the requested deployment' do
        get :show, deployment_target_id: 44, id: 22, format: :json
        expect(response.body).to eq deployment.to_json
      end

      it 'returns a HTTP 200 status code' do
        get :show, deployment_target_id: 44, id: 22, format: :json
        expect(response.status).to eq 200
      end
    end

    context 'when the resource does not exist' do
      let(:error_message) { 'deployment not found' }

      before do
        deployment_service.stub(:find).with('13').and_raise(error_message)
      end

      it 'returns the requested deployment' do
        get :show, deployment_target_id: 44, id: 13, format: :json
        expect(response.body).to eq "{\"message\":\"#{error_message}\"}"
      end

      it 'returns a HTTP 500 status code' do
        get :show, deployment_target_id: 44, id: 13, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'POST #create' do

    let(:template) do
      Template.new(
        name: 'wordpress application',
        description: 'blog'
      )
    end

    let(:override) do
      {
        'name' => 'wordpress application',
        'description' => 'glob'
      }
    end

    let(:post_args) do
      {
        deployment_target_id: 44,
        template_id: 21,
        override: override,
        format: :json
      }
    end

    before do
      Template.stub(:find).with(21).and_return(template)
      deployment_service.stub(:create).and_return(deployment)
    end

    it 'turns the override into a Template' do
      expect(TemplateBuilder).to receive(:create).with(override)
      post :create, post_args
    end

    it 'creates the deployment' do
      expect(deployment_service).to receive(:create)
        .with(template: template, override: instance_of(Template))

      post :create, post_args
    end

    it' returns the created deployment' do
      post :create, post_args
      expect(response.body).to eq deployment.to_json
    end

    it 'returns an HTTP 201 status code' do
      post :create, post_args
      expect(response.status).to eq 201
    end

    context 'when the given template does not exist' do
      before do
        Template.stub(:find).with(13).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns an HTTP 500 status code' do
        post :create, deployment_target_id: 44, template_id: 13, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'DELETE #destroy' do

    before do
      deployment_service.stub(:destroy)
    end

    it 'removes the given deployment' do
      expect(deployment_service).to receive(:destroy).with('13')
      delete :destroy, deployment_target_id: 44, id: 13, format: :json
    end

    it 'returns an HTTP 204 status code' do
      delete :destroy, deployment_target_id: 44, id: 13, format: :json
      expect(response.status).to eq 204
    end
  end
end
