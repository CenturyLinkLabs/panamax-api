class AddDisabledColumnToRegistries < ActiveRecord::Migration
  def change
    add_column :registries, :enabled, :boolean, default: true
  end
end
