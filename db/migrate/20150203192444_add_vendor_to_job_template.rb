class AddVendorToJobTemplate < ActiveRecord::Migration
  def change
    add_column :job_templates, :vendor, :string
  end
end
