class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.text :description
      t.text :from
      t.text :ports
      t.text :expose
      t.text :environment
      t.text :command
      t.text :volumes
      t.string :type
      t.references :app, index: true
    end

    add_index :services, :name
  end
end
