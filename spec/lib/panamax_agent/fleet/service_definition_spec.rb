require 'spec_helper'

describe PanamaxAgent::Fleet::ServiceDefinition do

  let(:name) { 'myservice.service' }

  let(:attrs) do
    {
      description: 'description',
      after: 'after',
      requires: 'requires',
      exec_start_pre: 'exec_start_pre',
      exec_start: 'exec_start',
      exec_start_post: 'exec_start_post',
      exec_reload: 'exec_reload',
      exec_stop: 'exec_stop',
      exec_stop_post: 'exec_stop_post',
      restart_sec: 'restart_sec',
      timeout_start_sec: 'timeout_start_sec'
    }
  end

  subject { described_class.new(name) }

  it { should respond_to :name }
  it { should respond_to :description }
  it { should respond_to :after }
  it { should respond_to :requires }
  it { should respond_to :exec_start_pre }
  it { should respond_to :exec_start }
  it { should respond_to :exec_start_post }
  it { should respond_to :exec_reload }
  it { should respond_to :exec_stop }
  it { should respond_to :exec_stop_post }
  it { should respond_to :restart_sec }
  it { should respond_to :timeout_start_sec }

  describe '#initialize' do

    subject { described_class.new(name, attrs) }

    its(:name) { should eql name }
    its(:description) { should eql attrs[:description] }
    its(:after) { should eql attrs[:after] }
    its(:requires) { should eql attrs[:requires] }
    its(:exec_start_pre) { should eql attrs[:exec_start_pre] }
    its(:exec_start) { should eql attrs[:exec_start] }
    its(:exec_start_post) { should eql attrs[:exec_start_post] }
    its(:exec_stop) { should eql attrs[:exec_stop] }
    its(:exec_stop_post) { should eql attrs[:exec_stop_post] }
    its(:restart_sec) { should eql attrs[:restart_sec] }
    its(:timeout_start_sec) { should eql attrs[:timeout_start_sec] }

    context 'when a block is specified' do

      it 'yields itself' do
        yielded_instance = nil
        new_instance = described_class.new(name) { |i| yielded_instance = i }
        expect(yielded_instance).to be new_instance
      end
    end
  end

  describe '#unit_def' do

    subject { described_class.new(name, attrs) }

    it 'provides a fleet formatted unit definition' do
      raw = <<UNIT_FILE
[Unit]
Description=#{attrs[:description]}
After=#{attrs[:after]}
Requires=#{attrs[:requires]}

[Service]
ExecStartPre=#{attrs[:exec_start_pre]}
ExecStart=#{attrs[:exec_start]}
ExecStartPost=#{attrs[:exec_start_post]}
ExecReload=#{attrs[:exec_reload]}
ExecStop=#{attrs[:exec_stop]}
ExecStopPost=#{attrs[:exec_stop_post]}
Restart=always
RestartSec=#{attrs[:restart_sec]}
TimeoutStartSec=#{attrs[:timeout_start_sec]}
UNIT_FILE

      expected = {
        'Contents' => {
          'Unit' => {
            'Description' => [attrs[:description]],
            'After' => [attrs[:after]],
            'Requires' => [attrs[:requires]]
          },
          'Service' => {
            'ExecStartPre' => [attrs[:exec_start_pre]],
            'ExecStart' => [attrs[:exec_start]],
            'ExecStartPost' => [attrs[:exec_start_post]],
            'ExecReload' => [attrs[:exec_reload]],
            'ExecStop' => [attrs[:exec_stop]],
            'ExecStopPost' => [attrs[:exec_stop_post]],
            'Restart' => ['always'],
            'RestartSec' => [attrs[:restart_sec]],
            'TimeoutStartSec' => [attrs[:timeout_start_sec]]
          }
        },
        'Raw' => raw
      }

      expect(subject.unit_def).to eq expected
    end

    context 'when the after attribute is an enumerable' do

      let(:after) { ['a', 'b'] }

      subject { described_class.new('foo', after: after) }

      it 'generates a space-delimited list of after requirements' do
        expected = {
          'Contents' => {
            'Unit' => {
              'After' => [after.join(' ')]
            },
            'Service' => {
              'Restart' => ['always']
            }
          }
        }

        expect(subject.unit_def).to include expected
      end
    end

    context 'when the requires attribute is an enumerable' do

      let(:requires) { ['a', 'b'] }

      subject { described_class.new('foo', requires: requires) }

      it 'generates a space-delimited list of requires requirements' do
        expected = {
          'Contents' => {
            'Unit' => {
              'Requires' => [requires.join(' ')]
            },
            'Service' => {
              'Restart' => ['always']
            }
          }
        }

        expect(subject.unit_def).to include expected
      end
    end
  end

  describe '#job_def' do

    subject { described_class.new(name, attrs) }

    it 'generates the appropriate job definition' do

      expected = {
        'Name' => name,
        'UnitHash' => [233, 172, 244, 146, 29, 162, 149, 234, 49, 88, 53, 82, 252, 40, 2, 57, 31, 67, 218, 225]
      }

      expect(subject.job_def).to eq expected
    end
  end

  describe '#sha1' do

    subject { described_class.new(name, attrs) }

    it 'generates the appropriate sha1 hash' do

      expect(subject.sha1).to eq "e9acf4921da295ea31583552fc2802391f43dae1"
    end
  end
end
