class JobTemplate < ActiveRecord::Base
  has_many :steps, -> { order(:position) }, class_name: 'JobTemplateStep'
  has_many :jobs

  serialize :environment, Array

  scope :cluster_job_templates, -> { where(type: 'ClusterJobTemplate') }

  def self.load_templates(pathname)
    pathname.each_child do |template|
      template_contents = YAML.safe_load(template.read || '')
      JobTemplateBuilder.create(template_contents)
    end
  end

  def override(other_template)
    self.environment.each do |var|
      overidden = other_template.environment.find { |env| env['variable'] == var['variable'] }
      if overidden
        var.merge!(overidden)
        other_template.environment.delete(overidden)
      end
    end
    env = environment.concat(other_template[:environment])
    self.environment = env
  end
end
