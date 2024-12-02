# frozen_string_literal: true

module Types
  class EmailType < Types::BaseObject
    field :address, String
    field :verified_at, GraphQL::Types::ISO8601DateTime, null: true
    field :login_link, Boolean
    field :verify_link, Boolean

    def verify_link
      object.login_links.active.for_verification.any?
    end

    def login_link
      object.for_login? && object.login_links.active.for_login.any?
    end

    def log_in
      object.for_login?
    end
  end
end
