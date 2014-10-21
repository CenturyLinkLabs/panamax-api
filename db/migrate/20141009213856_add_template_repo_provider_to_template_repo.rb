class AddTemplateRepoProviderToTemplateRepo < ActiveRecord::Migration
  def change
    add_reference :template_repos, :template_repo_provider, index: true
  end
end
