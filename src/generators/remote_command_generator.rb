module Foobara
  module RemoteGenerator
    module Generators
      class RemoteCommandGenerator < TypescriptFromManifestBaseGenerator
        def import_destructure
          ts_instance_path.first
        end

        def ts_instance_path
          ["RemoteCommand"]
        end

        def ts_instance_full_path
          ["RemoteCommand"]
        end

        def template_path
          ["base", "RemoteCommand.ts.erb"]
        end

        def hash
          template_path.hash
        end

        def domain_reference
          "global_organization::global_domain"
        end

        # TODO: awkward to have this here hmmm... maybe create a manifest for these static files?
        # something doesn't feel right about this.
        def domain
          Manifest::Domain.new(root_manifest, [:domain, domain_reference])
        end

        def scoped_full_name
          ts_instance_path.first
        end
      end
    end
  end
end
