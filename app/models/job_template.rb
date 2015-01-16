class JobTemplate < ActiveRecord::Base
  has_many :steps, -> { order(:order) }, class_name: 'JobTemplateStep'
  has_many :jobs

  serialize :environment, Array

  scope :cluster_job_templates, -> { where(type: 'ClusterJobTemplate') }

  def self.load_templates(pathname)
    pathname.each_child do |template|
      JobTemplateBuilder.create(template.read)
    end
  end

  def override(other_template)

  end
end
