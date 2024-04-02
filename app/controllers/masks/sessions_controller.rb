# frozen_string_literal: true

module Masks
  # @visibility private
  class SessionsController < ApplicationController
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
          path =
            (
              if masked_session.passed?
                session.delete(:return_to) || masked_session.mask.pass ||
                  Masks.configuration.site_links[:after_login]
              else
                masked_session.mask.fail ||
                  Masks.configuration.site_links[:login]
              end
            )
          redirect_to path
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

    def resource_cls
      Masks.configuration.model(:session_json)
    end
  end
end
