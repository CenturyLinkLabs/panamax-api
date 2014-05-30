require 'spec_helper'

describe App do
  subject { apps(:app1) }
  it { should have_many(:services) }
  it { should have_many(:categories).class_name('AppCategory').dependent(:destroy) }

  describe '.create_from_template' do
    let(:template) { templates(:wordpress) }

    context 'creates a new app' do
      it 'when using values from the template, has a unique name' do
        result = App.create_from_template(template)
        result.reload
        expect(result.name).to eq template.name
        expect(result.from).to eq "Template: #{template.name}"
        expect(result.documentation).to eq template.documentation
      end

      it 'when using the same template again, has a unique name' do
        result = ''
        2.times {
          result = App.create_from_template(template)
          result.reload
        }
        expect(result.name).to eq "#{template.name}_1"
        expect(result.from).to eq "Template: #{template.name}"
      end

      it 'and updates a category, name is not affected' do
        app = App.create_from_template(template)
        app.reload
        expect(app.name).to eq template.name
        expect(app.from).to eq "Template: #{template.name}"
        app.categories = [AppCategory.new(name: 'My Category')]
        app.save
        app.reload
        expect(app.name).to eq template.name
      end

    end

    context 'with an associated image' do
      let(:associated_image) do
        image_params = {
            name: 'MySql',
            description: 'a database',
            repository: 'foo',
            tag: 'bar',
            links: [],
            ports: [{ 'container_port' => '8080' }],
            expose: ['expose this'],
            environment: {var: 'val'},
            volumes: ['volumes']
        }
        Image.new(image_params)
      end

      before do
        template.images << associated_image
      end

      it 'creates a service for each image' do
        expect {
          App.create_from_template(template)
        }.to change { Service.count }.by(1)
      end
    end

    context 'with images with multiple categories' do
      before do
        i1 = Image.create(name: 'image 1', categories: [TemplateCategory.create(name: 'cat 1', template: template)])
        i2 = Image.create(name: 'image 2', categories: [TemplateCategory.create(name: 'cat 2', template: template)])
        template.images = [i1,i2]
      end

      it 'copies the categories over like a boss' do
        new_app = App.create_from_template(template)
        expect(new_app.categories.map(&:name)).to match_array ['cat 1', 'cat 2']
        expect(new_app.services.first.categories.first.name).to eq 'cat 1'
        expect(new_app.services.first.categories.first.app_category.app_id).to eq new_app.id
        expect(new_app.services.last.categories.first.name).to eq 'cat 2'
        expect(new_app.services.last.categories.first.app_category.app_id).to eq new_app.id
      end
    end

    context 'with images with a shared category' do
      before do
        c = TemplateCategory.create(name: 'cat 1', template: template)
        i1 = Image.create(name: 'image 1', categories: [c])
        i2 = Image.create(name: 'image 2', categories: [c])
        template.images = [i1,i2]
      end

      it 'creates category associated with the app' do
        new_app = App.create_from_template(template)
        expect(new_app.categories.count).to eq 1
        expect(new_app.categories.first.name).to eq 'cat 1'
        expect(new_app.categories.first.app_id).to eq new_app.id
      end

      it 'assigns the same category to both images' do
        new_app = App.create_from_template(template)
        s1, s2 = new_app.services
        expect(s1.categories.count).to eq 1
        expect(s1.categories.first.app_category_id).to eq s2.categories.first.app_category_id
      end
    end

    context 'with linked images' do

      before do
        i1 = Image.create(name: 'WP', links: [{ 'service' => 'MYSQL', 'alias' => 'DB' }])
        i2 = Image.create(name: 'MYSQL')
        template.images = [i1, i2]
      end

      it 'creates a service link between linked images' do
        new_app = App.create_from_template(template)
        s1, s2 = new_app.services
        expect(s1.links.count).to eq 1
        expect(s1.links.first.alias).to eq 'DB'
        expect(s1.links.first.linked_to_service).to eq s2
      end
    end
  end

  describe '.create_from_image' do

    let(:params) do
      {
          image: 'foo/bar:baz',
          links: [{service: 'MYSQL', alias: 'DB'}],
          ports: [{ host_interface: '', host_port: '', 'container_port' => '90', proto: '' }],
          expose: ['3306'],
          environment: {'SOME_KEY' => ''},
          volumes: [{host_path: '', container_path: ''}]
      }
    end

    it 'creates a new app from the params' do
      result = App.create_from_image(params)
      result.reload
      expect(result.name).to eq 'foo_bar:baz'
      expect(result.from).to eq 'Image: foo/bar:baz'
    end

    it 'creates a new app from the same image again' do
      result = ''
      2.times {
        result = App.create_from_image(params)
        result.reload
      }
      expect(result.name).to eq 'foo_bar:baz_1'
      expect(result.from).to eq 'Image: foo/bar:baz'
    end

    it 'creates a service from the params' do
      expect {
        App.create_from_image(params)
      }.to change { Service.count }.by(1)
    end

    it 'associates the service with the app' do
      result = App.create_from_image(params)
      result.reload
      expect(result.services.count).to eq(1)
      expect(Service.last.app).to eq result
    end
  end

  describe '#run' do

    let(:s1) { Service.new(name: 's1') }
    let(:s2) { Service.new(name: 's2') }

    before do
      subject.services = [s1, s2].each { |s| s.stub(submit: true, start: true) }
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
      subject.run
    end

    it 'runs each service' do
      expect(s1).to receive(:start)
      expect(s2).to receive(:start)
      subject.run
    end
  end

  describe '#restart' do

    let(:s1) { Service.new(name: 's1') }
    let(:s2) { Service.new(name: 's2') }

    before do
      subject.stub(:sleep)
      subject.services = [s1, s2]
      subject.services.each do |s|
        s.stub(:shutdown)
        s.stub(:submit)
        s.stub(:start)
      end
    end

    it 'shutsdown each service' do
      expect(s1).to receive(:shutdown)
      expect(s2).to receive(:shutdown)
      subject.restart
    end

    it 'does some sleeping' do
      expect(subject).to receive(:sleep).with(1)
      subject.restart
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
      subject.restart
    end

    it 'starts each service' do
      expect(s1).to receive(:start)
      expect(s2).to receive(:start)
      subject.restart
    end
  end

  describe '#add_service' do

    fixtures :app_categories

    let(:category) { subject.categories.first }

    let(:params) do
      {
        name: 'foo_bar',
        description: 'my foo service',
        from: 'some image',
        categories: [{ id: category.id }],
        ports: [{ host_interface: '', host_port: '', 'container_port' => 90, proto: '' }],
        expose: [''],
        links: [],
        volumes: [{ host_path: '', container_path: '' }],
        environment: { 'SOME_KEY' => '' }
      }
    end

    before do
      subject.stub(:resolve_name_conflicts).and_return(true)
    end

    it 'creates a new service' do
      result = subject.add_service(params)
      expect(result.name).to eq params[:name]
      expect(result.from).to eq params[:from]
    end

    it 'increments the service count' do
      expect {
        subject.add_service(params)
      }.to change { Service.count }.by(1)
    end

    it 'adds the service to the existing app' do
      subject.add_service(params)
      subject.reload
      expect(Service.last.app).to eq subject
    end

    it 'increments the app services count' do
      expect {
        subject.add_service(params)
        subject.reload
      }.to change { subject.services.count }.by(1)
    end

    it 'associates the service to the correct category' do
      subject.add_service(params)
      subject.reload
      expect(Service.last.categories.first.app_category_id).to eq category.id
    end
  end

end
