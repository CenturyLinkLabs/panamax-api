require 'rake/task'

class Docker::Image

  class << self

    def new_search(query = {}, connection = Docker.connection)
      # Given a query like `{ :term => 'sshd' }`, queries the Docker Registry for
      # a corresponding Image.
      body = connection.get('/images/search', query)
      hashes = Docker::Util.parse_json(body) || []
      #hashes.map { |hash| new(connection, 'id' => hash['name']) }
      hashes.map { |hash| new(connection, hash.merge('id' => hash['name'])) }
    end

    alias_method :search, :new_search
  end

end