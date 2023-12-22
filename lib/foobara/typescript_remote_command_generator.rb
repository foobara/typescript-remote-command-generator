require "foobara/all"

require "erb"
require "json"
require "open-uri"

require "remote_generator"

src = "#{__dir__}/../../src/"

Foobara::Util.require_directory(src)

module TypescriptRemoteCommandGenerator
end
