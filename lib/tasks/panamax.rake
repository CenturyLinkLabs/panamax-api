namespace :panamax do
  namespace :templates do
    desc 'Load templates from all registered repositories'
    task :load => :environment do
      Template.load_templates_from_template_repos
    end
  end
end
