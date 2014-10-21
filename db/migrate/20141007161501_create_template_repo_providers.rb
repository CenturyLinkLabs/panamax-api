class CreateTemplateRepoProviders < ActiveRecord::Migration
  def change
    create_table :template_repo_providers do |t|
      t.string :type
      t.string :name
      t.string :credentials_account
      t.text :credentials_api_key
      t.references :user, index: true
      t.timestamps
    end
  end
end
