require 'spec_helper'

require 'panamax_agent/fleet/service_definition'

describe PanamaxAgent::Fleet::Client do

  describe '#submit' do

    let(:service_def) { PanamaxAgent::Fleet::ServiceDefinition.new('foo.service') }

    before do
      subject.stub(:receive_payload).and_return(nil)
    end

    it 'invokes #create_payload' do
      expect(subject).to receive(:create_payload)
        .with(service_def.name, service_def.to_hash)

      subject.submit(service_def)
    end
  end

  describe '#start' do

    let(:service_name) { 'foo.service' }
    let(:payload) do
      {
        'node' => {
          'value' => "{ \"name\": \"#{service_name}\" }"
        }
      }
    end

    before do
      subject.stub(:get_payload).and_return(payload)
      subject.stub(:create_job).and_return(nil)
    end

    it 'invokes #get_payload' do
      expect(subject).to receive(:get_payload)
        .with(service_name)
        .and_return(payload)

      subject.start(service_name)
    end

    it 'invokes #create_job' do
      expected_job = {
        "Name" => service_name,
        "JobRequirements" => {},
        "Payload" => JSON.parse(payload['node']['value']),
        "State" => nil
      }

      expect(subject).to receive(:create_job)
        .with(service_name, expected_job)
        .and_return(nil)

      subject.start(service_name)
    end
  end
end
