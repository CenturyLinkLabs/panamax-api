# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


unless User.any?
  User.create(github_access_token: '4afd3519b925cd38bb1b04398de783266859ca47')
end

TemplateRepo.find_or_create_by(name: 'CenturyLinkLabs/panamax-templates-test')
