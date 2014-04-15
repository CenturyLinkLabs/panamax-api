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
      restart_sec: 'restart_sec'
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

    context 'when a block is specified' do

      it 'yields itself' do
        yielded_instance = nil
        new_instance = described_class.new(name) { |i| yielded_instance = i }
        expect(yielded_instance).to be new_instance
      end
    end
  end

  describe '#to_hash' do

    subject { described_class.new(name, attrs) }

    it 'provides a JSON formatted service definition' do
      expected = {
        'Name' => name,
        'Unit' => {
          'Contents' => {
            'Unit' => {
              'Description' => attrs[:description],
              'After' => attrs[:after],
              'Requires' => attrs[:requires]
            },
            'Service' => {
              'ExecStartPre' => attrs[:exec_start_pre],
              'ExecStart' => attrs[:exec_start],
              'ExecStartPost' => attrs[:exec_start_post],
              'ExecReload' => attrs[:exec_reload],
              'ExecStop' => attrs[:exec_stop],
              'ExecStopPost' => attrs[:exec_stop_post],
              'RestartSec' => attrs[:restart_sec],
              'Restart' => 'always',
            }
          }
        }
      }

      expect(subject.to_hash).to eq expected
    end

    context 'when the service name does not end in .service' do

      subject { described_class.new('foo') }

      it 'appends .service to the service name' do
        expected = {
          'Name' => 'foo.service',
          'Unit' => {
            'Contents' => {
              'Unit' => {},
              'Service' => {
                'Restart' => 'always'
              }
            }
          }
        }

        expect(subject.to_hash).to eq expected
      end
    end

    context 'when the after attribute is an enumerable' do

      let(:after) { ['a', 'b'] }

      subject { described_class.new('foo', after: after) }

      it 'generates a space-delimited list of after requirements' do
        expected = {
          'Name' => 'foo.service',
          'Unit' => {
            'Contents' => {
              'Unit' => {
                'After' => after.join(' ')
              },
              'Service' => {
                'Restart' => 'always'
              }
            }
          }
        }.to_hash

        expect(subject.to_hash).to eq expected
      end
    end

    context 'when the requires attribute is an enumerable' do

      let(:requires) { ['a', 'b'] }

      subject { described_class.new('foo', requires: requires) }

      it 'generates a space-delimited list of requires requirements' do
        expected = {
          'Name' => 'foo.service',
          'Unit' => {
            'Contents' => {
              'Unit' => {
                'Requires' => requires.join(' ')
              },
              'Service' => {
                'Restart' => 'always'
              }
            }
          }
        }

        expect(subject.to_hash).to eq expected
      end
    end
  end
end
