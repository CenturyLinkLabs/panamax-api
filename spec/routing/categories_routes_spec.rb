require 'spec_helper'

describe 'categories routes' do

  it 'routes GET to the app categories controller index' do
    expect(get: '/apps/1/categories').to route_to(
      controller: 'categories',
      action: 'index',
      app_id: '1'
    )
  end

  it 'routes POST to the app categories controller create action' do
    expect(post: '/apps/1/categories').to route_to(
       controller: 'categories',
       action: 'create',
       app_id: '1'
    )
  end

  it 'routes PUT to the app categories controller update action' do
    expect(put: '/apps/1/categories/2').to route_to(
       controller: 'categories',
       action: 'update',
       app_id: '1',
       id: '2'
    )
  end

  it 'routes DELETE to the app categories controller destroy action' do
    expect(delete: '/apps/1/categories/2').to route_to(
       controller: 'categories',
       action: 'destroy',
       app_id: '1',
       id: '2'
    )
  end
end
