class AddVolumesFromToServices < ActiveRecord::Migration
  def change
    add_column :services, :volumes_from, :text
  end
end
