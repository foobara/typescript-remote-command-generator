module Foobara
  module RemoteGenerator
    foobara_domain!

    foobara_register_type(:env_expression, :string, one_of: ["import.meta.env", "process.env"])

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

      def with_env_expression(env_expression)
        old = @env_expression

        begin
          @env_expression = env_expression
          yield
        ensure
          @env_expression = old
        end
      end

      attr_reader :env_expression
    end
  end
end
