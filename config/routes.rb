# frozen_string_literal: true

Masks::Engine.routes.draw do
  get "/debug", to: "debug#show" if Rails.env.development?

  # signup/login
  get "session", to: "sessions#new", as: :session
  post "session", to: "sessions#create"
  delete "session", to: "sessions#destroy"

  # recover credentials
  get "recover", to: "recoveries#new", as: :recover
  post "recover", to: "recoveries#create"
  get "recovery", to: "recoveries#password", as: :recover_password
  post "recovery", to: "recoveries#reset"

  # manage account details, password, etc
  get "me", to: "actors#current", as: :current
  get "password", to: "passwords#edit", as: :password
  post "password", to: "passwords#update"
  post "device/:key", to: "devices#update", as: :device

  # manage emails
  get "emails", to: "emails#new", as: :emails
  post "emails", to: "emails#create"
  patch "emails", to: "emails#notify"
  delete "emails", to: "emails#delete"
  get "email/:email/verify", to: "emails#verify", as: :email_verify

  # keys
  get "keys", to: "keys#new", as: :keys
  post "keys", to: "keys#create"
  delete "keys", to: "keys#delete"

  # manage 2nd factor options
  get "one-time-codes", to: "one_time_code#new", as: :one_time_code
  post "one-time-codes", to: "one_time_code#create"
  delete "one-time-codes", to: "one_time_code#destroy"
  get "backup-codes", to: "backup_codes#new", as: :backup_codes
  post "backup-codes", to: "backup_codes#create"

  # OAuth/OpenID support
  get "client/:id/.well-known/openid-configuration",
      to: "openid/discoveries#new",
      as: :openid_discovery
  get "client/:id/jwks.json", to: "openid/discoveries#jwks", as: :openid_jwks
  get "client/:id",
      to:
        redirect { |params, _|
          "client/#{params[:id]}/.well-known/openid-configuration"
        },
      as: :openid_issuer
  get "authorize", to: "openid/authorizations#new", as: :openid_authorization
  post "authorize", to: "openid/authorizations#create"
  post "token",
       to: proc { |env| Masks::OpenID::Token.new.call(env) },
       as: :openid_token
  match "userinfo",
        to: "openid/userinfo#show",
        via: %i[get post],
        as: :openid_userinfo

  # managers-only section
  namespace :manage do
    get "/", to: "dashboard#index"

    # manage clients
    get "clients", to: "clients#index", as: :clients
    post "clients", to: "clients#create"
    get "clients/:id", to: "clients#show", as: :client
    patch "clients/:id", to: "clients#update"
    delete "clients/:id", to: "clients#destroy"

    # manage actors
    get "actors", to: "actors#index", as: :actors
    get "actors/:actor", to: "actors#show", as: :actor
    patch "actors/:actor", to: "actors#update"
  end
end
