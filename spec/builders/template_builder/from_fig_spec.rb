require 'spec_helper'

describe TemplateBuilder::FromFig do

  let(:fig_yml) { File.open("#{Rails.root}/spec/support/fixtures/fig.yml").read }
  let(:options) do
    HashWithIndifferentAccess.new(
          'name' => 'figgy-template',
          'description' => 'some template',
          'keywords' => 'foo,baz,bar',
          'authors' => [],
          'documentation' => '---\n\nBlah\n\n',
          'type' => 'wordpress',
          'fig_yml' => fig_yml
    )
  end

  subject { described_class.new options }

  context '.create_template' do
    it 'creates a template from the fig.yml' do
      expect(subject.create_template).to be_a(Template)
    end

    describe 'assigns the options provided to the template' do
      subject { described_class.new(options).create_template }
      its(:name) { should eq options[:name] }
      its(:description) { should eq options[:description] }
      its(:keywords) { should eq options[:keywords] }
      its(:type) { should eq options[:type] }
      its(:documentation) { should eq options[:documentation] }

      it 'creates images for each service defined in fig.yml' do
        expect(subject.images.length).to eq(2)
        expect(subject.images.map(&:name)).to match_array(%w(web db))
        expect(subject.images.map(&:source)).to match_array(%w(wordpress mysql))
        expect(subject.images.find_by(name: 'web').ports).to eq([{ 'host_port' => '8080', 'container_port' => '80' }])
        expect(subject.images.find_by(name: 'db').ports).to be_blank
        expect(subject.images.find_by(name: 'web').links).to eq([{ 'service' => 'db', 'alias' => 'db' }])
        expect(subject.images.find_by(name: 'db').links).to be_blank
        expect(subject.images.find_by(name: 'web').environment).to eq([
          { 'variable' => 'MYSQL_PORT_3306_TCP_ADDR', 'value' => '172.17.0.4' },
          { 'variable' => 'WORDPRESS_DB_PASSWORD', 'value' => 'mysecretpassword' }
        ])
        expect(subject.images.find_by(name: 'db').environment).to eq([
          { 'variable' => 'MYSQL_ROOT_PASSWORD', 'value' => 'mysecretpassword' }
        ])
        expect(subject.images.find_by(name: 'web').volumes).to eq([
          {
            'host_path' => 'cache/',
            'container_path' => '/tmp/cache'
          }
        ])
        expect(subject.images.find_by(name: 'db').volumes).to be_blank
        expect(subject.images.find_by(name: 'web').expose).to be_blank
        expect(subject.images.find_by(name: 'db').expose).to eq(['3306'])
        expect(subject.images.find_by(name: 'web').volumes_from).to be_blank
        expect(subject.images.find_by(name: 'db').volumes_from).to eq([{ 'service' => 'web' }])
      end
    end

    it 'persists the template if the json data is valid' do
      expect(subject.create_template).to be_persisted
    end

    it 'returns the template with errors if the fig.yml is not supported' do
      invalid_fig_yml = options.merge('fig_yml' => "wordpress:\n  build:\n    .")
      strategy = described_class.new invalid_fig_yml
      expect(strategy.create_template).to_not be_valid
      expect(strategy.create_template).to_not be_persisted
      expect(strategy.create_template.errors).to_not be_empty
    end

    context 'when persisted flag is false' do
      it 'returns an unpersisted template ' do
        t = subject.create_template(false)
        expect(t.persisted?).to be_falsey
      end
    end
  end

end
