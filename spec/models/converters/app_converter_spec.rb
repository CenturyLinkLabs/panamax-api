require 'spec_helper'

describe Converters::AppConverter do

  subject { described_class.new(apps(:app1)) }

  context '#to_template' do
    fixtures :apps

    it 'creates a Template from the given App' do
      expect(subject.to_template).to be_a Template
    end

    it "converts the App's Services to the Template's Images" do
      expect(subject.to_template.images.size).to eq apps(:app1).services.size
    end
  end

  context '#to_compose_yaml' do
    fixtures :apps, :services

    it 'creates a yaml string from the given App' do
      expect(subject.to_compose_yaml).to be_a String
    end

    it 'creates a yaml representation with the same services as the App' do
      yaml = subject.to_compose_yaml
      rb = YAML.load(yaml)
      expect(rb.keys).to match_array apps(:app1).services.map(&:name)
    end
  end

  context '#to_compose_gist' do
    fixtures :apps, :services

    let(:github_client) { double('github_client', create_gist: {}) }
    let(:create_params) do
      {
        description: 'created by Panamax',
        public: true,
        files: { 'docker-compose.yml' => { content: subject.to_compose_yaml } }
      }
    end

    before do
      allow(Octokit::Client).to receive(:new).and_return(github_client)
    end

    it 'uses Octokit to create a new gist' do
      expect(github_client).to receive(:create_gist).with(create_params)
      subject.to_compose_gist
    end
  end
end
