class CreateTemplateRepos < ActiveRecord::Migration
  def change
    create_table :template_repos do |t|
      t.string :name

      t.timestamps
    end

    add_index :template_repos, :name, unique: true
  end
end
