module Masks
  module Internal
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        if skipped?(request)
          @app.call(env)
        else
          session = env["masks.session"] = Session.new(env)
          device = env["masks.device"] = Tracking.device(session)

          @app.call(env)
        end
      end

      private

      def skipped?(request)
        skipped_paths.include?(request.path)
      end

      def skipped_paths
        @skipped_paths ||=
          (Masks.env.routes&.to_h || {})
            .entries
            .map { |path, opts| opts[:skip] ? path.to_s : nil }
            .compact
      end
    end
  end
end
