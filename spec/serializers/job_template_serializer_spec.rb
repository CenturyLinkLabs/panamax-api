require 'spec_helper'

describe JobTemplateSerializer do
  fixtures :job_templates

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(job_templates(:cluster_job_template)).as_json
    expected_keys = [:id, :name, :description, :documentation, :environment, :steps]
    expect(serialized.keys).to match_array expected_keys
  end

end
