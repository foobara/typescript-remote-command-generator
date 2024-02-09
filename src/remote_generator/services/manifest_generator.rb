require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ManifestGenerator < BaseGenerator
        def generate
          JSON.pretty_generate(relevant_manifest.relevant_manifest)
        end
      end
    end
  end
end