class AddAdapterToJobTemplate < ActiveRecord::Migration
  def change
    add_column :job_templates, :adapter, :string
  end
end
