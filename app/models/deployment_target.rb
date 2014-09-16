# LOCAL ONLY

require 'active_resource'

class DeploymentTarget < ActiveRecord::Base

  def list_deployments
    remote_deployment_model.all
  end

  def get_deployment(deployment_id)
    remote_deployment_model.find(deployment_id)
  end

  def create_deployment(template)
    remote_deployment_model.create(template: template)
  end

  def delete_deployment(deployment_id)
    remote_deployment_model.delete(deployment_id)
  end

  private

  # Class for Deployment model is dynamically generated because we need
  # to be able to set the site at runtime based on the endpoint for the
  # specific deployment target
  def remote_deployment_model
    site_url = self.endpoint_url
    Class.new(RemoteDeployment) do
      self.site = site_url
      self.element_name = 'deployment'
    end
  end
end
