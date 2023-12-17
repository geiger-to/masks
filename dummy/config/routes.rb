Rails.application.routes.draw do
  mount Masks::Engine => "/"

  unless Rails.env.production?
    get "/anon", to: "test#anon"
    get "/public", to: "test#public"
    get "/private", to: "test#private"
  end
end
