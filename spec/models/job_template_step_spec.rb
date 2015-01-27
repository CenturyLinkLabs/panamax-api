require 'spec_helper'

describe JobTemplateStep do
  it { should belong_to(:job_template) }
  it { should respond_to?(:environment) }
end
