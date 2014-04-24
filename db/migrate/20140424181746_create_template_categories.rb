class CreateTemplateCategories < ActiveRecord::Migration
  def change
    create_table :template_categories do |t|
      t.references :template, index: true
      t.string :name
      t.integer :position

      t.timestamps
    end

    add_index :template_categories, [:name, :template_id], unique: true
  end
end
