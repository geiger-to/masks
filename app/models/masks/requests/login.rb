# frozen_string_literal: true
module Masks
  module Requests
    class Login < ApplicationModel
      attribute :request
      attribute :tenant
      attribute :hint
      attribute :password
      attribute :actors
      attribute :nonce
      attribute :device

      validates :actor, presence: true
      validates :identifier, presence: true
      validates :valid_actor?, presence: true
      validates :valid_identifiers?, presence: true
      validates :valid_password?, presence: true
      validates :valid_scopes?, presence: true
      validates :password,
                length: {
                  minimum: ->(login) do
                    login.profile.setting(:password, :minimum).to_i
                  end,
                  maximum: ->(login) do
                    login.profile.setting(:password, :maximum).to_i
                  end
                },
                if: :password

      delegate :hint, to: :nonce

      def client
        @client ||=
          if request.params[:client_id]
            tenant.clients.find_by(key: request.params[:client_id])
          elsif nonce.openid_qs
            tenant.clients.find_by(key: nonce.openid_params[:client_id])
          else
            tenant.client
          end
      end

      def profile
        @profile ||= client&.profile
      end

      def identifier
        if hint
          profile.identifier(value: hint)
        elsif actor
          actor.identifier
        end
      end

      def valid_actor?
        actor&.valid?
      end

      def valid_identifiers?
        return true unless actor&.signup

        added = actor.identifiers.map(&:key)
        required = profile.signup_identifiers.keys

        (required - added).any?
      end

      def scopes
        @scopes ||= nonce.openid_params ? nonce.openid_params[:scope].split : []
      end

      def valid_scopes?
        return true unless actor
        return true if scopes.empty?

        # requested scopes must be a subset of what's required
        (scopes - actor.scopes).none?
      end

      def logins_allowed?
        profile.enabled?(:logins) && profile.identifiers.keys.any?
      end

      def signups_allowed?
        profile.enabled?(:signups) && profile.identifiers.keys.any?
      end

      def signup?
        return false unless logins_allowed?
        return false unless signups_allowed?
        return false unless identifier

        !actor || actor&.signup
      end

      def valid_password?
        return false unless actor

        checked?(:password, actor:)
      end

      def password_error
        return unless password.present?

        errors.full_messages_for(:password).first
      end

      def verify!
        return unless actor

        checked(:actor, actor.uuid, actor:)

        return unless password

        checked(:password, actor.authenticate(password).present?, actor:)
      end

      def complete!(approved: false, denied: false)
        uri =
          if already_complete?
            checked_value(:redirect_uri, actor:)
          elsif client.internal?
            actor.access_tokens.create!(
              tenant:,
              client:,
              device: device.record,
              scopes: client.scopes
            )

            if client.valid_redirect_uri?(nonce.redirect_uri)
              nonce.redirect_uri
            else
              client.redirect_uris.first
            end
          elsif approved || denied
            approved ? openid.approve! : openid.deny!

            openid.redirect_uri
          end

        actor.touch(:last_login_at) if actor && valid?
        checked(:redirect_uri, uri, actor:)
      end

      def already_complete?
        checked?(:redirect_uri, actor:) &&
          (
            !nonce.redirect_uri ||
              nonce.redirect_uri == checked_value(:redirect_uri, actor:)
          )
      end

      def redirect_uri
        if checked?(:redirect_uri, actor:)
          checked_value(:redirect_uri, actor:)
        else
          nonce.redirect_uri
        end
      end

      def openid
        @openid ||=
          Masks::Requests::OpenID.new(
            tenant:,
            profile:,
            client:,
            actor:,
            request:,
            device:,
            query: nonce.openid_qs
          )
      rescue Rack::OAuth2::Server::Authorize::BadRequest
        nil
      end

      attr_writer :actor

      def actor
        @actor ||= (profile.find_actor(identifier: hint) if hint)
      end

      delegate :checked, :checked?, :checked_value, :last_actor, to: :actors
    end
  end
end
