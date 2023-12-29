module Foobara
  module RemoteGenerator
    class Services
      class DependencyGroup
        class CollisionData
          attr_accessor :points

          def collisions_for_points
            @collisions_for_points ||= {}
          end
        end

        attr_accessor :dependencies, :name

        def initialize(dependencies, name:)
          self.name = name
          self.dependencies = dependencies.to_set

          dependencies.each do |dep|
            if dep.belongs_to_dependency_group
              # :nocov:
              raise "Dependency group #{dep} already belongs to dependency group #{dep.dependency_group}"
              # :nocov:
            end

            dep.belongs_to_dependency_group = self
          end

          find_collisions
        end

        def collision_data_for(dep)
          key = to_key(dep)

          collision_data[key].tap do |cd|
            unless cd
              # :nocov:
              raise "Dependency #{dep} is not part of this dependency group"
              # :nocov:
            end
          end
        end

        def set_collision_data_for(dep, collision_data)
          key = to_key(dep)
          self.collision_data[key] = collision_data
        end

        def to_key(dep)
          [dep.scoped_category, *dep.ts_instance_full_path].map(&:to_s)
        end

        def collision_data
          @collision_data ||= {}
        end

        def non_colliding_dependency_roots
          roots = Set.new

          dependencies.each do |dep|
            roots << non_colliding_root(dep)
          end

          roots
        end

        def non_colliding_root(dep)
          root = dep
          points = points_for(dep)
          points_climbed = 0

          until points_climbed >= points
            # TODO: can't use scoped_path because sometimes we want UnloadedUser instead of User. How to fix??
            points_climbed += dep.scoped_path.size
            root = root.parent
          end

          root
        end

        def points_for(dep)
          points = collision_data_for(dep).points

          unless points
            # :nocov:
            raise "Dependency #{dep} has no collision data"
            # :nocov:
          end

          points
        end

        def non_colliding_name(dep, points = points_for(dep))
          non_colliding_path(dep, points).join(".")
        end

        def non_colliding_type(dep, points = points_for(dep))
          name = non_colliding_name(dep, points)

          if name.include?(".")
            case dep
            when Manifest::Domain, Services::DomainGenerator, Manifest::Organization, Services::OrganizationGenerator,
              Manifest::Error, Services::ErrorGenerator
              "typeof #{name}"
            when Manifest::Command, Services::CommandGenerator, Manifest::Entity, Services::EntityGenerator
              "InstanceType<typeof #{name}>"
            else
              # :nocov:
              raise "Not sure how to handle #{name} for #{dep}"
              # :nocov:
            end
          else
            name
          end
        end

        def non_colliding_path(dep, points = points_for(dep))
          start_at = dep.ts_instance_full_path.size - points - 1
          path = dep.ts_instance_full_path[start_at..] || []
          path.map(&:to_s)
        end

        private

        def find_collisions
          dependencies.each do |dep|
            collision_data = CollisionData.new

            points = 0

            loop do
              name = non_colliding_name(dep, points)

              collisions = dependencies.select do |other_dep|
                dep != other_dep && name == non_colliding_name(other_dep, points)
              end

              if collisions.empty?
                collision_data.points = points
                set_collision_data_for(dep, collision_data)
                break
              else
                collision_data.collisions_for_points[points] = collisions
                points += 1
              end
            end
          end
        end
      end
    end
  end
end
