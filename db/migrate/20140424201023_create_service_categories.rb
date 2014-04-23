class CreateServiceCategories < ActiveRecord::Migration
  def change
    create_table :service_categories do |t|
      t.references :service, index: true
      t.references :app_category, index: true
      t.integer :position

      t.timestamps
    end

    add_index :service_categories, [:service_id, :app_category_id], unique: true
  end
end
