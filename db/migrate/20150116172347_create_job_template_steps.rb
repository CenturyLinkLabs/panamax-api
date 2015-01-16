class CreateJobTemplateSteps < ActiveRecord::Migration
  def change
    create_table :job_template_steps do |t|
      t.string :name
      t.string :source
      t.text :environment
      t.integer :order
      t.references :job_template, index: true

      t.timestamps
    end
  end
end
