require 'spec_helper'

describe 'keyword routes' do

  it 'routes to the index action of the keyword controller' do
    expect(get: '/keywords').to route_to(
      controller: 'keywords',
      action: 'index',
    )
  end
end
