require 'spec_helper'

describe 'user routes' do

  it 'routes GET to the users controller show action' do
    expect(get: '/user').to route_to(
       controller: 'users',
       action: 'show'
    )
  end

  it 'routes PUT to the users controller update action' do
    expect(put: '/user').to route_to(
       controller: 'users',
       action: 'update'
    )
  end
end
