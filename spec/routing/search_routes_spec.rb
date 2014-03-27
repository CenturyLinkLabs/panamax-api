require 'spec_helper'

describe 'search routes' do

  it 'routes get to the search controller search index' do
    expect(get: '/search?q=panamax').to route_to(
        controller: 'search',
        action: 'index',
        q: 'panamax'
    )
  end

  it 'has a named route for the search controller search action' do
    expect(get: search_path).to route_to(
        controller: 'search',
        action: 'index'
    )
  end

end