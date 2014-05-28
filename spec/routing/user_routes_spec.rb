require 'spec_helper'

describe 'user routes' do

  it 'routes PUT to the users controller update action' do
    expect(put: '/user').to route_to(
       controller: 'users',
       action: 'update'
    )
  end
end
