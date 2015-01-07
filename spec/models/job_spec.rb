require 'spec_helper'

describe Job do
  it { should belong_to(:job_template) }
  it { should have_many(:job_steps) }
end
