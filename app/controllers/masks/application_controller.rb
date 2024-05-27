# frozen_string_literal: true

module Masks
  # @visibility private
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    skip_before_action :verify_authenticity_token, if: :json_request?

    protect_from_forgery with: :exception

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    helper_method :tenant, :client, :profile, :setting
    helper_method :dark_mode?, :dark_mode_allowed?, :theme

    private

    def device
      @device ||= Masks::Sessions::Device.new(request:, tenant:)
    end

    def client
      nil
    end

    def profile
      nil
    end

    def setting(*args)
      profile&.setting(*args) || tenant&.setting(*args)
    end

    def theme
      dark_mode? ? setting(:dark_mode, :theme) : setting(:theme)
    end

    def dark_mode_allowed?
      setting(:dark_mode, :enabled)
    end

    def dark_mode?
      dark_mode_allowed? ? cookies[:default_theme] == "dark" : false
    end

    def tenant_key
      "masks:#{tenant.key || "unknown"}"
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

    def render_not_found
      render "masks/404", layout: "masks/application", status: :not_found
    end
  end
end
