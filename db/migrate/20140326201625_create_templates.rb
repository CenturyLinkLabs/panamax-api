class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.text :description
      t.string :keywords
      t.text :authors
      t.boolean :recommended
      t.string :from
      t.string :type
      t.text :documentation

      t.timestamps
    end

    add_index :templates, :keywords
    add_index :templates, :name

    create_table :images do |t|
      t.string :image_id
      t.string :name
      t.string :source
      t.text :description
      t.string :categories
      t.boolean :recommended
      t.string :type
      t.text :links
      t.text :ports
      t.text :expose
      t.text :environment
      t.text :volumes
      t.integer :template_id

      t.timestamps
    end

    add_index :images, :image_id, unique: true
    add_index :images, :source

  end
end
