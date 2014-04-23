class CreateAppCategories < ActiveRecord::Migration
  def change
    create_table :app_categories do |t|
      t.string :name
      t.references :app
      t.integer :position

      t.timestamps
    end

    add_index :app_categories, [:name, :app_id], unique: true
  end
end
