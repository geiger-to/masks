# frozen_string_literal: true
module Masks
  module Rails
    module OpenID
      class Authorization < ApplicationRecord
        self.table_name = "openid_authorizations"

        scope :valid, -> { where("expires_at >= ?", Time.now.utc) }

        belongs_to :actor, class_name: Masks.configuration.models[:actor]
        belongs_to :openid_client,
                   class_name: Masks.configuration.models[:openid_client]

        serialize :scopes, coder: JSON

        after_initialize :generate_code

        validates :actor, presence: true
        validates :openid_client, presence: true
        validates :code, presence: true, uniqueness: true
        validates :expires_at, presence: true

        def valid_redirect_uri?(uri)
          uri == redirect_uri
        end

        def access_token
          @access_token ||=
            update_attribute!(:expires_at, Time.now) && generate_access_token!
        end

        def generate_access_token!
          actor.openid_access_tokens.create!(openid_client:, scopes:)
        end

        private

        def generate_code
          return if code

          self.code = SecureRandom.uuid
          self.expires_at = 5.minutes.from_now
        end
      end
    end
  end
end
