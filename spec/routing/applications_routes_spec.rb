require 'spec_helper'

describe 'apps routes' do

  it 'routes get to the apps controller index' do
    expect(get: '/apps').to route_to(
        controller: 'apps',
        action: 'index'
    )
  end

  it 'has a named route for the apps controller index' do
    expect(get: apps_path).to route_to(
                                          controller: 'apps',
                                          action: 'index'
                                      )
  end

  it 'routes get with an id to a the apps controller show action' do
    expect(get: '/apps/1').to route_to(
                                        controller: 'apps',
                                        action: 'show',
                                        id: '1'
                                    )
  end

  it 'has a named route for the apps controller show action' do
    expect(get: app_path(1)).to route_to(
                                            controller: 'apps',
                                            action: 'show',
                                            id: '1'
                                        )
  end

  it 'routes post to the apps controller create action' do
    expect(post: '/apps').to route_to(
        controller: 'apps',
        action: 'create'
                                     )
  end
end