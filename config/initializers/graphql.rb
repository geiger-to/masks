module GraphQL
  module Define
    class DefinedObjectProxy
      include Rails.application.routes.url_helpers
      include ActionController::Helpers
    end
  end
end
