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
            if dep.dependency_group
              raise "Dependency group #{dep} already has a dependency group #{dep.dependency_group}"
            end

            dep.belongs_to_dependency_group = self
          end

          find_collisions
        end

        def collisions
          @collisions ||= {}
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
          path = non_colliding_path(points_for(dep))
          root = root.parent until root.full_scoped_path == path
          root
        end

        def points_for(dep)
          collisions[dep].points
        end

        def non_colliding_name(dep, points = points_for(dep))
          non_colliding_path(dep, points).join(".")
        end

        def non_colliding_path(dep, points = points_for(dep))
          scoped_full_path[dep.scoped_full_path.size - points..].map(&:to_s)
        end

        private

        def find_collisions
          dependencies.each do |dep|
            record = collisions[dep] = CollisionData.new

            points = 0

            loop do
              name = non_colliding_name(dep, points)

              collisions = dependencies.select do |other_dep|
                dep != other_dep && name == non_colliding_name(other_dep, points)
              end

              if collisions.empty?
                record.points = points
              else
                record.collisions_for_points[points] = collisions
                points += 1
              end
            end
          end
        end
      end
    end
  end
end
