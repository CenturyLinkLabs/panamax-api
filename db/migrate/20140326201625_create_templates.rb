class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.text :description
      t.string :keywords
      t.boolean :recommended
      t.string :icon

      t.timestamps
    end

    add_index :templates, :name

    create_table :images do |t|
      t.string :image_id
      t.string :name
      t.string :repository
      t.string :tag
      t.text :description
      t.string :keywords
      t.boolean :recommended
      t.string :icon
      t.text :links
      t.text :ports
      t.text :expose
      t.text :environment
      t.text :volumes

      t.timestamps
    end

    add_index :images, :image_id, unique: true
    add_index :images, :repository

    create_table :images_templates do |t|
      t.belongs_to :template
      t.belongs_to :image
    end
  end
end
