class TemplateRepo < ActiveRecord::Base

  DEFAULT_PROVIDER_NAME = 'Github Public'

  belongs_to :template_repo_provider

  after_create :reload_templates
  after_destroy :purge_templates
  after_initialize :set_default_provider

  validates :name, presence: true, uniqueness: true

  def set_default_provider
    self.template_repo_provider ||= TemplateRepoProvider.where(name: DEFAULT_PROVIDER_NAME).first!
  end

  def files
    template_repo_provider.files_for(self)
  end

  def load_templates
    self.files.each do |file|
      next unless file.name.end_with?('.pmx')
      TemplateBuilder.create(file.content).tap { |tpl| tpl.update_attributes(source: self.name) }
    end
    self.touch
  end

  def purge_templates
    Template.destroy_all(source: self.name)
  end

  def reload_templates
    transaction do
      purge_templates
      load_templates
    end
  end

  def self.load_templates_from_all_repos
    self.all.each(&:load_templates)
  end

end
