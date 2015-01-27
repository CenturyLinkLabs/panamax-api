namespace :panamax do
  namespace :templates do
    desc 'Populate local template cache from all registered repositories'
    task :load => :environment do
      TemplateRepo.load_templates_from_all_repos
    end

    desc 'Clear local template cache'
    task :unload => :environment do
      Template.destroy_all
    end
  end

  namespace :job_templates do
    desc 'Load job templates from file system'
    task :load => :environment do
      JobTemplate.load_templates(Rails.root.join('db','job_templates'))
    end
  end
end
