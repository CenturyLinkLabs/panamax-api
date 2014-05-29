require 'spec_helper'

describe 'template routes' do

  it 'routes get to the templates controller index' do
    expect(get: '/templates').to route_to(
                                            controller: 'templates',
                                            action: 'index'
                                         )
  end

  it 'has a named route for the templates controller index action' do
    expect(get: templates_path).to route_to(
                                    controller: 'templates',
                                    action: 'index'
                                )
  end

  it 'routes get with an id to the templates controller show' do
    expect(get: '/templates/1').to route_to(
                                     controller: 'templates',
                                     action: 'show',
                                     id: '1'
                                 )
  end

  it 'has a named route for the templates controller show action' do
    expect(get: template_path(1)).to route_to(
                                       controller: 'templates',
                                       action: 'show',
                                       id: '1'
                                   )
  end
end
