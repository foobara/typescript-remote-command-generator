module Foobara
  class FilesGenerator
    include TruncatedInspect

    class << self
      def generators_for(manifest, elements_to_generate)
        if manifest.is_a?(FilesGenerator)
          return [manifest]
        end

        generator_classes = manifest_to_generator_classes(manifest)

        Util.array(generator_classes).map do |generator_class|
          generator_class.new(manifest, elements_to_generate)
        end
      end

      def manifest_to_generator_classes(manifest)
        # :nocov:
        raise "subclass responsibility"
        # :nocov:
      end

      def generator_for(manifest, elements_to_generate = nil)
        generators_for(manifest, elements_to_generate).first
      end
    end

    attr_accessor :relevant_manifest, :elements_to_generate, :belongs_to_dependency_group

    def initialize(relevant_manifest, elements_to_generate)
      self.relevant_manifest = relevant_manifest
      self.elements_to_generate = elements_to_generate
    end

    def target_path
      # :nocov:
      raise "Subclass responsibility"
      # :nocov:
    end

    def target_dir
      target_path[0..-2]
    end

    def applicable?
      true
    end

    def generators_for(...)
      self.class.generators_for(...)
    end

    def generator_for(...)
      self.class.generator_for(...)
    end

    def dependencies
      # :nocov:
      raise "Subclass responsibility"
      # :nocov:
    end

    def generate
      unless elements_to_generate
        # :nocov:
        raise "This generator was created without elements_to_generate and therefore cannot be ran."
        # :nocov:
      end

      dependencies.each do |dependency|
        elements_to_generate << if dependency.is_a?(FilesGenerator)
                                  dependency.relevant_manifest
                                else
                                  dependency
                                end
      end

      # Render the template
      erb_template.result(binding)
    end

    def template_path
      # :nocov:
      raise "Subclass responsibility"
      # :nocov:
    end

    def absolute_template_path
      path = template_path

      if path.is_a?(::Array)
        path = path.join("/")
      end

      Pathname.new("#{__dir__}/../templates/#{path}").cleanpath.to_s
    end

    def template_string
      File.read(absolute_template_path)
    end

    def erb_template
      # erb = ERB.new(template_string.gsub("\n<% end %>", "<% end %>"))
      erb = ERB.new(template_string)
      erb.filename = absolute_template_path
      erb
    end

    def path_to_root
      size = target_path.size - 1

      (["../"] * size).join
    end

    def ==(other)
      # :nocov:
      raise "subclass responsibility"
      # :nocov:
    end

    def eql?(other)
      # :nocov:
      raise "subclass responsibility"
      # :nocov:
    end

    def hash
      # :nocov:
      raise "subclass responsibility"
      # :nocov:
    end
  end
end
