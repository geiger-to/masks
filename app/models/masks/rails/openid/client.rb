# frozen_string_literal: true
module Masks
  module Rails
    module OpenID
      class Client < ApplicationRecord
        include Masks::Scoped

        self.table_name = "openid_clients"

        validates :name, presence: true

        after_initialize :generate_credentials
        before_validation :generate_key, on: :create

        serialize :scopes, coder: JSON
        serialize :redirect_uris, coder: JSON
        serialize :response_types, coder: JSON
        serialize :grant_types, coder: JSON

        validates :key, :secret, :scopes, presence: true
        validates :key, uniqueness: true
        validates :client_type,
                  inclusion: {
                    in: %w[public confidential]
                  },
                  presence: true
        validates :subject_type,
                  inclusion: {
                    in: Masks.configuration.openid[:subject_types]
                  },
                  presence: true
        validate :validate_expiries

        has_many :access_tokens,
                 class_name: Masks.configuration.models[:openid_access_token],
                 inverse_of: :openid_client
        has_many :authorizations,
                 class_name: Masks.configuration.models[:openid_authorization],
                 inverse_of: :openid_client
        has_many :saved_roles,
                 class_name: Masks.configuration.models[:role],
                 autosave: true

        def to_param
          key
        end

        def response_types
          case client_type
          when "confidential"
            ["code"]
          when "public"
            ["token", "id_token", "id_token token"]
          end
        end

        def grant_types
          case client_type
          when "confidential"
            %w[refresh_token authorization_code client_credentials]
          else
            []
          end
        end

        def scopes
          self[:scopes]
        end

        def roles(record, **opts)
          case record
          when Class, String
            saved_roles.where(record_type: record.to_s, **opts).includes(
              :record
            )
          else
            saved_roles.where(record:, **opts)
          end
        end

        def issuer
          Masks::Engine.routes.url_helpers.openid_issuer_url(
            id: key,
            host: Masks.configuration.site_url
          )
        end

        def kid
          :default
        end

        def private_key
          OpenSSL::PKey::RSA.new(rsa_private_key)
        end

        delegate :public_key, to: :private_key

        def subject(actor)
          case subject_type
          when "nickname"
            actor.nickname
          else
            Digest::SHA256.hexdigest(
              [
                sector_identifier,
                actor.actor_id,
                Masks.configuration.openid[:pairwise_salt]
              ].join("/")
            )
          end
        end

        def audience
          key
        end

        def auto_consent?
          !consent
        end

        def pairwise_subject?
          sector_identifier && subject_type == "pairwise"
        end

        def assign_scopes!(*scopes)
          self.scopes = [*scopes, *self.scopes].uniq.compact
          save!
        end

        def remove_scopes!(*scopes)
          scopes.each { |scope| self.scopes.delete(scope) }

          save!
        end

        def code_expires_at
          Time.now + ChronicDuration.parse(code_expires_in)
        end

        def token_expires_at
          Time.now + ChronicDuration.parse(token_expires_in)
        end

        def refresh_expires_at
          Time.now + ChronicDuration.parse(refresh_expires_in)
        end

        private

        def generate_credentials
          self.secret ||= SecureRandom.uuid
          self.client_type ||= "confidential"
          self.subject_type ||= "nickname"
          self.scopes ||= Masks.configuration.openid[:scopes] || []
          self.rsa_private_key ||= OpenSSL::PKey::RSA.generate(2048).to_pem
          self.sector_identifier ||=
            begin
              URI.parse(Masks.configuration.site_url).host
            rescue StandardError
              "masks"
            end
          self.code_expires_in ||= "5 minutes"
          self.token_expires_in ||= "1 day"
          self.refresh_expires_in ||= "1 week"
        end

        def generate_key
          return unless name

          key = name.parameterize
          count = self.class.where("key LIKE ?", "#{key}%").count

          self.key = count.positive? ? "#{key}-#{count + 1}" : key
        end

        def validate_expiries
          %i[
            code_expires_in
            token_expires_in
            refresh_expires_in
          ].each do |param|
            unless ChronicDuration.parse(send(param))
              errors.add(param, :invalid)
            end
          end
        end
      end
    end
  end
end
