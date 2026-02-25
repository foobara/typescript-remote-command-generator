module Foobara
  module RemoteGenerator
    foobara_domain!

    class << self
      def auto_dirty_queries(auto_dirty_queries)
        if auto_dirty_queries == @auto_dirty_queries
          yield
        else
          old = @auto_dirty_queries
          begin
            @auto_dirty_queries = auto_dirty_queries
            yield
          ensure
            @auto_dirty_queries = old
          end
        end
        @auto_dirty_queries = auto_dirty_queries
      end

      def auto_dirty_queries?
        @auto_dirty_queries
      end
    end
  end
end
