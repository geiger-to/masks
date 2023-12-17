# frozen_string_literal: true

module Masks
  # Helpers for interacting with Masks in Rails controllers.
  #
  # @see ClassMethods
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      # Require a session masked by the type passed.
      #
      # If this fails +unathorized_access+ is called.
      #
      # @param [Symbol|String] type
      # @param [Hash] opts forwarded to +before_action+
      def require_mask(type: nil, **opts)
        before_action(
          :unauthorized_access,
          unless: -> { masked?(type:) },
          **opts
        )
      end

      # Builds an access object by the passed name, if allowed.
      #
      # If this succeeds, the controller instance's +current_access+ will return
      # the constructed access class.  Otherwise, on failure the
      # +unathorized_access+ method is called.
      #
      # @example
      #   class MyController < ApplicationController
      #     include Masks::Controller
      #
      #     require_access 'my.example', only: :index
      #
      #     # this action is only called if the session is
      #     # able to build the "my.example" access class.
      #     def index
      #       render json: {
      #         foobar: current_access.foo_bar
      #       }
      #     end
      #   end
      #
      # @param [Symbol|String] name
      # @param [Hash] opts forwarded to +before_action+
      def require_access(name, **opts)
        before_action(
          :unauthorized_access,
          unless: -> { build_access(name) },
          **opts
        )
      end
    end

    protected

    def passed?
      current_actor && masked_session.passed?
    end

    def unauthorized_access
      render plain: "", status: :unauthorized
    end

    # Returns the current masks session for the request.
    #
    # @return [Masks::Session]
    # @visibility public
    def masked_session
      @masked_session ||= request.env[Masks::Middleware::SESSION_KEY]
    end

    # Returns the mask for the request.
    #
    # @return [Masks::Mask]
    # @visibility public
    def current_mask
      masked_session.mask
    end

    # Returns the mask for the request.
    #
    # @return [Masks::Actor]
    # @visibility public
    def current_actor
      masked_session.scoped
    end

    # Returns the mask for the request.
    #
    # @return [Masks::Access]
    # @visibility public
    def current_access
      @current_access
    end

    def build_access(name)
      @current_access = Masks.access(name, masked_session)
    rescue Masks::Error::Unauthorized
      false
    end

    def masked?(type: nil)
      if type &&
           !Array.wrap(type).map(&:to_s).include?(masked_session.mask.type)
        false
      else
        masked_session.passed?
      end
    end
  end
end
