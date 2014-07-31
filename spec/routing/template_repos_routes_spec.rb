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

  it 'routes DELETE to the template repos controller destroy action' do
    expect(delete: '/template_repos/1').to route_to(
       controller: 'template_repos',
       id: "1",
       action: 'destroy'
    )
  end

  it 'routes POST to a specific repo /reload to the reload action' do
    expect(post: 'template_repos/1/reload').to route_to(
       controller: 'template_repos',
       id: "1",
       action: 'reload'
    )
  end
end
