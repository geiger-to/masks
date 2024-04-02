module Masks
  module Rails
    module OpenID
      class Client < ApplicationRecord
        self.table_name = 'openid_clients'

        validates :name, presence: true

        after_initialize :generate_credentials

        serialize :scopes, coder: JSON
        serialize :redirect_uris, coder: JSON
        serialize :response_types, coder: JSON

        validates :subject_type, inclusion: { in: Masks.configuration.openid[:subject_types] }, presence: true
        validates :response_types, presence: true
        validates :redirect_uris, presence: true
        validates :scopes, presence: true

        has_many :access_tokens, class_name: Masks.configuration.models[:openid_access_token], 
inverse_of: :openid_client
        has_many :authorizations, class_name: Masks.configuration.models[:openid_authorization], 
inverse_of: :openid_client

        def private_key
          OpenSSL::PKey::RSA.new(rsa_private_key)
        end

        def private_key_id
          :default
        end

        def subject(actor)
          Digest::SHA256.hexdigest([sector_identifier, actor.actor_id, pairwise_salt].join('/'))
        end

        def issuer
          Masks.configuration.site_url
        end

        def audience
          key
        end

        def auto_consent?
          !consent
        end

        def pairwise_subject?
          sector_identifier && subject_type == 'pairwise'
        end

        private

        def generate_credentials
          self.key ||= SecureRandom.uuid
          self.secret ||= SecureRandom.uuid
          self.scopes ||= Masks.configuration.openid[:scopes] || []
          self.response_types ||= Masks.configuration.openid[:response_types]
          self.rsa_private_key ||= OpenSSL::PKey::RSA.generate(2048).to_pem
          self.pairwise_salt ||= SecureRandom.uuid
          self.subject_type ||= 'public'
        end

        def sector_identifier
          return unless sector_identifier_uri

          URI.parse(sector_identifier_uri).host
        rescue URI::InvalidURIError
          nil
        end
      end
    end
  end
end
