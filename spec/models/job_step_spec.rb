require 'spec_helper'

describe JobStep do
  it { should belong_to(:job) }
  it { should respond_to?(:environment) }
end
