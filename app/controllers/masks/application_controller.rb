# frozen_string_literal: true

module Masks
  # @visibility private
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    skip_before_action :verify_authenticity_token, if: :json_request?

    protect_from_forgery with: :exception

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    helper_method :tenant, :setting, :masked
    helper_method :dark_mode?, :dark_mode_allowed?, :theme
    helper_method :profile, :client, :login, :openid

    delegate :client, :openid, to: :login
    delegate :profile, to: :client, allow_nil: true

    before_action :validate_device

    private

    def device
      @device ||= Masks::Sessions::Device.new(request:, tenant:)
    end

    def login
      @login ||= Masks::Requests::Login.new(tenant:, request:, nonce:, actors:, device:)
    end

    def nonce
      @nonce ||= Masks::Sessions::Nonce.new(request:, tenant:)
    end

    def actors
      @actors ||= Masks::Sessions::Actors.new(request:, tenant:, hint: nonce.hint)
    end

    def setting(*args)
      profile&.setting(*args) || tenant&.setting(*args)
    end

    def current_actor
      login.actor
    end

    def theme
      dark_mode? ? setting(:dark_mode, :theme) : setting(:theme)
    end

    def dark_mode_allowed?
      setting(:dark_mode, :enabled)
    end

    def dark_mode?
      dark_mode_allowed? ? cookies[:default_theme] == 'dark' : false
    end

    def tenant_key
      "masks:#{tenant.key || 'unknown'}"
    end

    def tenant_id
      @tenant_id ||= params[:tenant_id] || Masks.configuration.data[:tenant]
    end

    def tenant
      @tenant ||= Masks::Tenant.find_by!(key: tenant_id)
    end

    def json_request?
      request.format.symbol == :json
    end

    def validate_device
      render 'masks/device' unless device.known? && device.record.save
    end

    def render_not_found
      render 'masks/404', layout: 'masks/application', status: :not_found
    end
  end
end
