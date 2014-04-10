# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

wp = Template.create(
  name: 'Wordpress',
  description: 'This is a wordpress template',
  recommended: false
)
wp.images.create(
  repository: 'foo/wordpress',
  tag: '3.9',
  description: 'Wordpress 3.9',
  links: [{service: 'foo_mysql', alias:'db'}],
  ports: [{host_interface: '0.0.0.0', host_port: 80, container_port: 80, proto: 'tcp'}],
  expose: [80],
  environment: { 'MY_ENV_KEY' => 'my_env_value' },
  volumes: [{host_path: '/home/core', container_path: '/var/www'}]
)
wp.images.create(
  repository: 'foo/mysql',
  tag: 'latest',
  description: 'The latest and greatest mysql',
  expose: [3306]
)

Template.create(
  name: 'Apache',
  description: 'This is a reccomended apache template',
  recommended: true
)
