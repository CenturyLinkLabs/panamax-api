class AddInternalNameToService < ActiveRecord::Migration

  def up
    add_column :services, :internal_name, :string

    Service.all.each do |s|
      s.update_attribute(:internal_name, s.name)
    end
  end

  def down
    remove_column :services, :internal_name
  end

end
