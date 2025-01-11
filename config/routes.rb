Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  mount MissionControl::Jobs::Engine,
        at: "/manage/jobs",
        constraints: Masks::ManagerConstraint.new

  post "/graphql", to: "graphql#execute"

  # Image uploads
  post "/upload/logo", to: "uploads/installation#logo"
  post "/upload/favicon", to: "uploads/installation#favicon"
  post "/upload/client", to: "uploads/client#create"
  post "/upload/avatar", to: "uploads/avatar#create"

  # Manage accounts, sessions, and more...
  get "/manage", to: "manage#index"
  get "/manage/*url", to: "manage#index"

  # Authorize (including using the OIDC spec)
  match "/sso/:provider_id",
        via: %w[get post],
        to: "providers#callback",
        as: :callback

  get "/authorize/:client_id", to: "authorize#new", as: :authorize
  get "/authorize", to: "authorize#new", as: :oidc

  # Tokens
  post "token", to: proc { |env| TokensController.new.call(env) }

  # OAuth/OpenID support
  get "/.well-known/:client/openid-configuration",
      to: "oidc/discoveries#new",
      as: :oidc_discovery
  get "/jwks/:client", to: "oidc/discoveries#jwks", as: :oidc_jwks

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", :as => :pwa_manifest
end

Rails.application.routes.default_url_options = {
  protocol: Masks.uri.scheme,
  host: Masks.uri.hostname,
  port: Masks.uri.port,
}.compact
