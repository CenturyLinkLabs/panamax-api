require 'spec_helper'

describe 'repositories routes' do

  it 'routes GET to the repositories controller show action' do
    expect(get: '/repositories/foo/bar').to route_to(
       controller: 'repositories',
       action: 'show',
       id: 'foo/bar'
    )
  end
end
