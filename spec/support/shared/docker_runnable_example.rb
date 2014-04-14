require 'spec_helper'

shared_examples_for "a docker runnable model" do
  let(:name) { 'FOO' }
  let(:from) { 'panamax/image' }

  let(:model) { described_class.new(name: name, from: from) }

  context "when no options specified" do

    it "generates the correct docker command" do
      expected = "/usr/bin/docker run --rm --name #{name} #{from}"
      expect(model.docker_run_string).to eq expected
    end
  end

  context "when links are specified" do

    before do
      model.links = [{ service: 'MYSQL', alias: 'DB' }]
    end

    it "generates a docker command with --link" do
      expected = '--link MYSQL:DB'
      expect(model.docker_run_string).to include expected
    end
  end

  context "when ports are specified" do

    before do
      model.ports = [{
        host_interface: '0.0.0.0',
        host_port: '8000',
        container_port: '3000',
        proto: 'tcp'
      }]
    end

    it "generates a docker command with -p" do
      expected = '-p 0.0.0.0:8000:3000/tcp'
      expect(model.docker_run_string).to include expected
    end
  end

  context "when exposed ports are specified" do

    before do
      model.expose = [ '8080' ]
    end

    it "generates a docker command with --expose" do
      expected = '--expose 8080'
      expect(model.docker_run_string).to include expected
    end
  end

  context "when environment vars are specified" do

    before do
      model.environment = { foo: :bar }
    end

    it "generates a docker command with -e" do
      expected = '-e "foo=bar"'
      expect(model.docker_run_string).to include expected
    end
  end

  context "when volumes are specified" do

    before do
      model.volumes = [{ host_path: '/tmp/foo', container_path: '/tmp/bar' }]
    end

    it "generates a docker command with -v" do
      expected = '-v /tmp/foo:/tmp/bar'
      expect(model.docker_run_string).to include expected
    end
  end
end
