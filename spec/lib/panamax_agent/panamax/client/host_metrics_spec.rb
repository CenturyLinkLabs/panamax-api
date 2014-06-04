require 'spec_helper'

describe PanamaxAgent::Panamax::Client::HostMetrics do

  subject { PanamaxAgent::Panamax::Client.new }

  let(:metrics_response) do
    { 'node' =>
      { 'value' => '{
        "load_average":"0.00",
        "cpu_idle":"90.9",
        "memory_free":"146.514",
        "cpu_cores":"2",
        "last_updated":"2014/06/04 02:12:51" }'
      }
    }
  end
  let(:metrics_data) do
    { 'host_metrics' =>
      {
        'load_average' => '0.00',
        'cpu_idle' => '90.9',
        'memory_free' => '146.514',
        'cpu_cores' => '2',
        'last_updated' => '2014/06/04 02:12:51'
      }
    }
  end

  describe '#list_host_metrics' do

    before do
      subject.stub(get: metrics_response)
    end

    it 'GETs the host metrics raw response' do
      expect(subject).to receive(:get)
                         .with('v2/keys/_panamax/host/metrics')
                         .and_return(metrics_response)

      subject.send(:get_host_metrics)
    end

    it 'returns the metrics meta' do
      expect(subject.list_host_metrics).to eql(metrics_data)
    end

    context 'when #get_host_metrics raises NotFound' do
      before do
        subject.stub(:get_host_metrics)
               .and_raise(PanamaxAgent::NotFound.new('boom'))
      end

      it 'return no metrics' do
        expect(subject.list_host_metrics).to eql('host_metrics' => {})
      end

    end

  end
end
