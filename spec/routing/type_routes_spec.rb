require 'spec_helper'

describe 'type routes' do

  it 'routes to the index action of the type controller' do
    expect(get: '/types').to route_to(
      controller: 'types',
      action: 'index',
    )
  end
end
