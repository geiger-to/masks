Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Masks.url

    resource "*", headers: :any, methods: %i[get post patch put]
  end
end
