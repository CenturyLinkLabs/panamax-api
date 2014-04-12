require 'spec_helper'

describe Service do
  it { should belong_to(:app) }

  it_behaves_like "a docker runnable model"
end
