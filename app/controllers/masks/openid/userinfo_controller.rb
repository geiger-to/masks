# frozen_string_literal: true
module Masks
  module OpenID
    class UserInfoController < ApplicationController
      def show
        claims = { sub: openid_client.subject(current_actor) }

        if access_token.scope?("email")
          claims[:email] = current_actor.primary_email&.email
        end

        if access_token.scope?("phone")
          claims[:phone] = current_actor.phone_number
        end

        render json: OpenIDConnect::ResponseObject::UserInfo.new(claims)
      end

      private

      def access_token
        @access_token ||= masked_session.extra(:access_token)
      end

      delegate :client, to: :access_token
    end
  end
end
