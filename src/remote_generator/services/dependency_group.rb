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

        attr_accessor :dependencies, :name, :will_define, :deps_are_for, :winners

        def initialize(dependencies, name:, deps_are_for:, will_define:, winners: nil)
          self.deps_are_for = deps_are_for
          self.will_define = will_define
          self.name = name
          self.dependencies = dependencies.to_set
          self.winners = [*winners] if winners

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
          points_climbed = dep.ts_instance_path.size

          until points_climbed >= points
            points_climbed += dep.ts_instance_path.size
            root = root.parent
          end

          root
        end

        def raw_points_for(dep)
          points = collision_data_for(dep).points

          unless points
            # :nocov:
            raise "Dependency #{dep} has no collision data"
            # :nocov:
          end

          points
        end

        def points_for(dep)
          if winners&.include?(dep)
            0
          else
            raw_points_for(dep)
          end
        end

        def non_colliding_type_name(dep, points = points_for(dep))
          non_colliding_type_path(dep, points).join(".")
        end

        def non_colliding_type(dep, points = points_for(dep))
          non_colliding_type_name(dep, points)
        end

        def non_colliding_type_path(dep, points = points_for(dep))
          if points == 0
            path = dep.ts_instance_path
            return path.size == 1 ? path : [path.last]
          end

          path = dep.ts_instance_path
          paths = [path]
          points_climbed = path.size

          until points_climbed >= points
            dep = dep.parent
            break unless dep

            path = dep.ts_instance_path
            paths.unshift(path)
            points_climbed += path.size
          end

          paths.flatten
        end

        private

        def find_collisions
          [deps_are_for, *dependencies].each do |dep|
            collision_data = CollisionData.new

            points = 0

            loop do
              name = non_colliding_type_name(dep, points)

              collisions = dependencies.select do |other_dep|
                dep != other_dep && name == non_colliding_type_name(other_dep, points)
              end

              if will_define&.include?(name)
                collisions << deps_are_for
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
