class CreateImageCategories < ActiveRecord::Migration
  def change
    create_table :image_categories do |t|
      t.references :image, index: true
      t.references :template_category, index: true
      t.integer :position

      t.timestamps
    end

    add_index :image_categories, [:image_id, :template_category_id], unique: true
  end
end
