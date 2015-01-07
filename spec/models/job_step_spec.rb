require 'spec_helper'

describe JobStep do
  it { should belong_to(:job_template) }
end
