require 'spec_helper'

describe TemplateCategory do
  it { should belong_to :template }
  it { should validate_uniqueness_of(:name).scoped_to(:template_id) }
  it { should validate_presence_of(:template_id) }
end
