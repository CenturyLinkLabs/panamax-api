class CreateJobSteps < ActiveRecord::Migration
  def change
    create_table :job_steps do |t|
      t.references :job_template, index: true
      t.integer :order
      t.string :name
      t.string :source
      t.text :environment

      t.timestamps
    end
  end
end
