require 'spec_helper'

describe 'local images routes' do

  it 'routes GET to the local images controller index action' do
    expect(get: '/local_images').to route_to(
      controller: 'local_images',
      action: 'index'
    )
  end

  it 'routes GET w/ image ID to the local images controller show action' do
    expect(get: '/local_images/1').to route_to(
       controller: 'local_images',
       action: 'show',
       id: '1'
    )
  end

  it 'routes GET w/ repo name to the local images controller show action' do
    expect(get: '/local_images/foo/bar').to route_to(
       controller: 'local_images',
       action: 'show',
       id: 'foo/bar'
    )
  end

  it 'routes DELETE to the local images controller destroy action' do
    expect(delete: '/local_images/1').to route_to(
       controller: 'local_images',
       action: 'destroy',
       id: '1'
    )
  end
end
