class CreateSharedVolumes < ActiveRecord::Migration
  def change
    create_table :shared_volumes do |t|
      t.references :exported_from_service, index: true
      t.references :mounted_on_service, index: true

      t.timestamps
    end

    add_index :shared_volumes, [:exported_from_service_id, :mounted_on_service_id], unique: true, name: 'index_shared_volume_keys'
  end
end
