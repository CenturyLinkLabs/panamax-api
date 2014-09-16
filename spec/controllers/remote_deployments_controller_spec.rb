require 'spec_helper'

describe RemoteDeploymentsController do
  let(:deployment_target) { DeploymentTarget.new }
  let(:deployment) { RemoteDeployment.new }
  let(:deployments) do
    [
      RemoteDeployment.new,
      RemoteDeployment.new
    ]
  end

  before do
    DeploymentTarget.stub(:find).with('44').and_return(deployment_target)
  end

  describe 'GET #index' do
    before do
      deployment_target.stub(:list_deployments).and_return(deployments)
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
    context 'when the resource exists' do
      before do
        deployment_target.stub(:get_deployment).with('22').and_return(deployment)
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
      before do
        deployment_target.stub(:get_deployment).with('13')
          .and_raise(ActiveResource::ResourceNotFound.new(double('err', code: '404')))
      end

      it 'returns the requested deployment' do
        get :show, deployment_target_id: 44, id: 13, format: :json
        expect(response.body).to eq "{\"message\":\"Failed.  Response code = 404.\"}"
      end

      it 'returns a HTTP 200 status code' do
        get :show, deployment_target_id: 44, id: 13, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'POST #create' do
    context 'when given a template id' do
      let(:template) do
        Template.new(
          name: 'wordpress application',
          description: 'blog'
        )
      end

      before do
        Template.stub(:find).with(21).and_return(template)
        deployment_target.stub(:create_deployment)
      end

      it 'creates the deployment' do
        expect(deployment_target).to receive(:create_deployment).with(TemplateFileSerializer.new(template).to_yaml)
        post :create, deployment_target_id: 44, template_id: 21, format: :json
      end

      it 'returns an HTTP 201 status code' do
        post :create, deployment_target_id: 44, template_id: 21, format: :json
        expect(response.status).to eq 201
      end

      context 'when the given template does not exist' do
        before do
          Template.stub(:find).with(13).and_raise(ActiveResource::ResourceNotFound.new(double('err', code: '404')))
        end

        it 'returns an HTTP 500 status code' do
          post :create, deployment_target_id: 44, template_id: 13, format: :json
          expect(response.status).to eq 500
        end
      end

      context 'when deployment creation fails' do
        before do
          deployment_target.stub(:create_deployment).and_raise
        end

        it 'returns an HTTP 500 status code' do
          post :create, deployment_target_id: 44, template_id: 21, format: :json
          expect(response.status).to eq 500
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      deployment_target.stub(:delete_deployment)
    end

    it 'removes the given deployment' do
      expect(deployment_target).to receive(:delete_deployment).with('13')
      delete :destroy, deployment_target_id: 44, id: 13, format: :json
    end

    it 'returns an HTTP 204 status code' do
      delete :destroy, deployment_target_id: 44, id: 13, format: :json
      expect(response.status).to eq 204
    end
  end
end
