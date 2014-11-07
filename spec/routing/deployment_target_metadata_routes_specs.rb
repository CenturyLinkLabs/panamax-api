require 'spec_helper'

describe 'deployment target metadata routes' do
  it 'can request a metadata refresh' do
    expect(post: '/deployment_targets/1/metadata/refresh').to route_to(
      controller: "remote_metadata_refreshes",
      action: "create",
      deployment_target_id: '1'
    )
  end
end
