class RemoteAgentMetadata < ActiveResource::Base
  self.element_name = 'metadata'
end

# Both of these must exist to support the nested keys in the
# RemoteAgentMetadata response, due to complications with the anonymous class.
# They're jammed in here because they only exist to make RemoteAgentMetadata
# work. They need a site for reasons that aren't clear to me, but it won't
# actually be hit because instances of these classes are never directly used.
class Agent < ActiveResource::Base
  self.site = "http://example.com"
end
class Adapter < ActiveResource::Base
  self.site = "http://example.com"
end
