require 'spec_helper'

describe 'Docker::Image patch' do

  let(:body) do
    {
        "description" => '',
        "is_official" => false,
        "is_trusted" => false,
        "name" => 'foo/bar',
        "star_count" => 0
    }
  end

  let(:connection) do
    conn = Docker::Connection.new('unix:///var/run/docker.sock', {})
    conn.stub(get: ([body].to_json))
    conn
  end

  let(:image) { Docker::Image.new(connection, body.merge("id" => body["name"])) }

  it "adds Docker index search result data to Docker::Image instances" do
    result = Docker::Image.search('blah', connection)
    expect(result.first.info).to eq image.info
  end

end