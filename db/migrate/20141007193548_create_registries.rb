class CreateRegistries < ActiveRecord::Migration
  def change
    create_table :registries do |t|
      t.string :name
      t.string :endpoint_url

      t.timestamps
    end
  end
end
