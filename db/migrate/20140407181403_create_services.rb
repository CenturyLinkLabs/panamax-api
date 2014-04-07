class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.string :from
      t.string :links
      t.string :ports
      t.string :expose
      t.text :environment
      t.text :volumes
      t.references :app, index: true
    end

    add_index :services, :name
  end
end
