namespace :panamax do
  namespace :templates do
    desc 'Populate local template cache from all registered repositories'
    task :load => :environment do
      using GithubAccessTokenOverride
      Template.load_templates_from_template_repos
    end

    desc 'Clear local template cache'
    task :unload => :environment do
      Template.destroy_all
    end
  end
end
