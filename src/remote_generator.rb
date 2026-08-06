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

      def no_foobara_auth(no_foobara_auth)
        old = @no_foobara_auth
        begin
          @no_foobara_auth = no_foobara_auth
          yield
        ensure
          @no_foobara_auth = old
        end
      end

      def no_foobara_auth?
        @no_foobara_auth
      end
    end
  end
end
