Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"

  # Image uploads
  post "/upload/logo", to: "uploads/logo#create"
  post "/upload/avatar", to: "uploads/avatar#create"

  # Manage accounts, sessions, and more...
  get "/manage", to: "manage#index"

  # Authorize (including using the OIDC spec)
  get "/authorize/:client_id", to: "authorize#new", as: :authorize
  get "/authorize", to: "authorize#new", as: :oidc

  # Webauthn support
  get "/webauthn", to: "webauth#new"
  post "/webauthn", to: "webauth#create"
  delete "/webauthn", to: "webauth#destroy"

  resources :webauthn, only: %i[new create destroy] do
    post :options, on: :collection, as: "options_for"
  end

  # resource :webauthn_credential_authentication, controller: 'webauthn_credential_authentication', only: [:new, :create] do
  # post :options, on: :collection, as: 'options_for'
  # end

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

  # Defines the root path route ("/")
  # root "posts#index"
end

Rails.application.routes.default_url_options = {
  protocol: Masks.uri.scheme,
  host: Masks.uri.hostname,
  port: Masks.uri.port,
}.compact
