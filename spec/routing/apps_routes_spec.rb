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

  describe 'services sub-resource routes' do
    it 'routes get to the app services controller index' do
      expect(get: '/apps/1/services').to route_to(
                                  controller: 'services',
                                  action: 'index',
                                  app_id: '1'
                              )
    end

    it 'has a named route for the app services controller index' do
      expect(get: app_services_path(1)).to route_to(
                                    controller: 'services',
                                    action: 'index',
                                    app_id: '1'
                                )
    end

    it 'routes get with an id to a the app services controller show action' do
      expect(get: '/apps/1/services/1').to route_to(
                                    controller: 'services',
                                    action: 'show',
                                    app_id: '1',
                                    id: '1'
                                )
    end

    it 'has a named route for the apps controller show action' do
      expect(get: app_service_path(1, 2)).to route_to(
                                      controller: 'services',
                                      action: 'show',
                                      app_id: '1',
                                      id: '2'
                                  )
    end

    it 'routes get journal to the app services controller journal action' do
      expect(get: '/apps/1/services/1/journal').to route_to(
                                   controller: 'services',
                                   action: 'journal',
                                   app_id: '1',
                                   id: '1'
                               )
    end

  end
end
