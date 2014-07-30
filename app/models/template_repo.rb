class TemplateRepo < ActiveRecord::Base

  after_destroy :purge_templates

  validates :name, presence: true, uniqueness: true

  def files
    GithubRepoFileEnumerator.new(name)
  end

  def purge_templates
    Template.destroy_all(source: self.name)
  end

end
