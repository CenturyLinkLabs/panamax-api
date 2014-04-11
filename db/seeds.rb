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
  recommended: true
)
wp.images.create(
  name: 'WP',
  repository: 'panamax/panamax-docker-wordpress',
  tag: 'latest',
  description: 'Wordpress',
  links: [{service: 'DB_1', alias:'DB_1'}],
  ports: [{host_port: 8080, container_port: 80}],
  expose: [80],
  environment: { 'DB_PASSWORD' => 'pass@word01' }
)
wp.images.create(
  name: 'DB_1',
  repository: 'panamax/panamax-docker-mysql',
  tag: 'latest',
  description: 'MySQL',
  expose: [3306],
  environment: { 'MYSQL_ROOT_PASSWORD' => 'pass@word01'},
  ports: [{host_port: 3306, container_port: 3306}]
)

rails = Template.create(
    name: 'Rails',
    description: 'This is a Rails app template',
    recommended: true
)
rails.images.create(
    name: 'DB',
    repository: 'dharmamike/dc-pgsql',
    tag: 'latest',
    description: 'PostgreSQL',
    ports: [{host_port: 5432, container_port: 5432}]
)
rails.images.create(
  name: 'APP',
  repository: 'dharmamike/dc-rails',
  tag: 'latest',
  description: 'welcome to rails',
  links: [{service: 'DB', alias:'DB_1'}],
  ports: [{host_port: 8088, container_port: 3000}]
)

Template.create(
  name: 'Apache',
  description: 'This is a reccomended apache template',
  recommended: false
)
