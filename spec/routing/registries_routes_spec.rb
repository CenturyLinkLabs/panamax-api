require 'spec_helper'

describe 'registries routes' do

  it 'routes GET to the registries controller show action' do
    expect(get: '/registries/1').to route_to(
       controller: 'registries',
       action: 'show',
       id: '1'
    )
  end

  it 'routes GET to the app registries controller index' do
    expect(get: '/registries').to route_to(
      controller: 'registries',
      action: 'index',
    )
  end

  it 'routes POST to the app registries controller create action' do
    expect(post: '/registries').to route_to(
       controller: 'registries',
       action: 'create',
    )
  end

  it 'routes PUT to the app registries controller update action' do
    expect(put: '/registries/2').to route_to(
       controller: 'registries',
       action: 'update',
       id: '2'
    )
  end

  it 'routes DELETE to the app registries controller destroy action' do
    expect(delete: '/registries/2').to route_to(
       controller: 'registries',
       action: 'destroy',
       id: '2'
    )
  end
end
