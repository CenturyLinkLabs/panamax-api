class CreateServiceLinks < ActiveRecord::Migration
  def change
    create_table :service_links do |t|
      t.references :linked_to_service, index: true
      t.references :linked_from_service, index: true
      t.string :alias

      t.timestamps
    end

    add_index :service_links, [:linked_from_service_id, :linked_to_service_id], unique: true, name: 'index_service_link_keys'
  end
end
