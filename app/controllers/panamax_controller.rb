class PanamaxController < ApplicationController
  respond_to :json

  def show
    respond_with panamax_client.list_components
  end

  def metrics
    respond_with panamax_client.list_host_metrics
  end

  private

  def panamax_client
    PanamaxAgent.panamax_client
  end

end
