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
              binding.pry
              raise "Dependency group #{dep} already belongs to dependency group #{dep.dependency_group}"
            end

            dep.belongs_to_dependency_group = self
          end

          find_collisions
        rescue => e
          binding.pry
          raise
        end

        def collision_data_for(dep)
          key = to_key(dep)
          collision_data[key].tap do |cd|
            unless cd
              raise "Dependency #{dep} is not part of this dependency group"
            end
          end
        end

        def set_collision_data_for(dep, collision_data)
          key = to_key(dep)
          self.collision_data[key] = collision_data
        end

        def to_key(dep)
          [dep.scoped_category.to_s, dep.scoped_full_path.map(&:to_s)]
        rescue => e
          binding.pry
          raise
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

            points_climbed += dep.scoped_path.size
            root = root.parent
          end

          root
        rescue => e
          binding.pry
          raise
        end

        def points_for(dep)
          points = collision_data_for(dep).points

          unless points
            raise "Dependency #{dep} has no collision data"
          end

          points
        rescue => e
          binding.pry
          raise
        end

        def non_colliding_name(dep, points = points_for(dep))
          non_colliding_path(dep, points).join(".")
        end

        def non_colliding_path(dep, points = points_for(dep))
          start_at = dep.scoped_full_path.size - points - 1
          dep.scoped_full_path[start_at..].map(&:to_s)
        rescue => e
          binding.pry
          raise
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
