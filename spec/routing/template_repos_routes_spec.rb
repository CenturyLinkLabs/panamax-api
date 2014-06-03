require 'spec_helper'

describe 'template repos routes' do

  it 'routes GET to the template repos controller index action' do
    expect(get: '/template_repos').to route_to(
      controller: 'template_repos',
      action: 'index'
    )
  end

  it 'routes POST to the template repos controller create action' do
    expect(post: '/template_repos').to route_to(
       controller: 'template_repos',
       action: 'create'
    )
  end
end
