class JobTemplate < ActiveRecord::Base
  has_many :job_steps, -> { order(:order) }

  serialize :environment, Array

  scope :cluster_job_templates, -> { where(type: 'ClusterJobTemplate') }

  def self.load_templates(pathname)
    pathname.each_child do |template|
      JobTemplateBuilder.create(template.read)
    end
  end
end
