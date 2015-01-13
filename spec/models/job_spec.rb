require 'spec_helper'

describe Job do

  it { should belong_to(:job_template) }
  it { should respond_to(:steps) }
  it { should respond_to(:steps=) }
  it { should respond_to?(:status)}

end
