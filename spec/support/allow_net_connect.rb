# This metadata, which is hopefully temporary, allows some specs to make
# network connections that currently are.
RSpec.configure do |c|
  c.before(allow_net_connect: true) { WebMock.allow_net_connect! }
  c.after { WebMock.disable_net_connect! }
end
