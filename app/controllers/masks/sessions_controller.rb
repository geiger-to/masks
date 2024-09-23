# frozen_string_literal: true

module Masks
  # @visibility private
  class SessionsController < ApplicationController
    before_action :set_identifiers

    helper_method :password_required?, :factor2_required?, :signup?

    layout 'masks/session'

    def new
      respond_to do |format|
        format.json { render json: resource_cls.new(masked_session) }
        format.html { render(:new) }
      end
    end

    def create
      flash[
        :errors
      ] = masked_session.errors.full_messages unless request.format == :json

      respond_to do |format|
        format.json { render json: resource_cls.new(masked_session) }
        format.html do
          redirect =
            (
              if masked_session.passed?
                session.delete(:return_to) || masked_session.mask.pass ||
                  Masks.configuration.site_links[:after_login]
              else
                masked_session.mask.fail
              end
            )

          if redirect
            redirect_to redirect
          else
            render 'new'
          end
        end
      end
    end

    def destroy
      masked_session.cleanup!

      respond_to do |format|
        format.json { render json: resource_cls.new(masked_session) }
        format.html do
          redirect_to Masks.configuration.site_links[:after_logout]
        end
      end
    end

    private

    def password_required?
      @session.checks[:password] && !@session.checks[:password].passed?
    end

    def factor2_required?
      checks = @session.checks

      return false unless checks

      checks[:factor2] && !checks[:factor2]&.passed? &&
        checks[:actor]&.passed? && checks[:password]&.passed?
    end

    def signup?
      masks_settings['signups.enabled'] && @actor&.signup
    end

    def set_identifiers
      @identifier = masks_config.identifiers.keys.map do |field|
        masks_config.identifier?(field) ? field : nil
      end.compact.sort.join('_')
    end

    def resource_cls
      masks_config.model(:session_json)
    end
  end
end
