class AddVolumesFromToImages < ActiveRecord::Migration
  def change
    add_column :images, :volumes_from, :text
  end
end
