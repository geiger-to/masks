# frozen_string_literal: true

module Masks
  # @visibility private
  class SessionsController < ApplicationController
    helper_method :profile, :client, :openid, :login

    delegate :client, :openid, to: :login
    delegate :profile, to: :client, allow_nil: true

    rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
      @error = e

      render :error, status: e.status
    end

    before_action do
      nonce.value = params[:nonce] if params[:nonce]
      nonce.clear_hint if params[:prompt] == 'select_account'
      nonce.hint = params[:login_hint] if params[:login_hint]
      nonce.redirect_uri = params[:redirect_uri] if params[:redirect_uri]
      nonce.openid_qs = request.query_string if openid_request?

      if !client || !profile
        render :not_found
      elsif !denied? && !login.logins_allowed?
        render :denied
      end
    end

    def new
      continue_login
    end

    def create
      if params[:signup]
        return redirect_to session_path(nonce: nonce.value) unless login.signup?

        login.actor = tenant.actors.build(signup: true)
        login.actor.identifiers << login.identifier
        login.actor.identifiers << nickname_id if nickname_id && nickname_id.key != login.identifier.key
        login.actor.identifiers << email_id if email_id && email_id.key != login.identifier.key
        login.actor.identifiers << phone_id if phone_id && phone_id.key != login.identifier.key
        login.actor.password = login.password = params[:password]
        login.actor.save
      else
        login.password = params[:password]
      end

      login.verify!

      continue_login
    end

    private

    def openid_request?
      params[:client_id] && params[:response_type] && params[:redirect_uri]
    end

    def continue_login
      if denied? || (login.valid? && approved?)
        login.complete!(approved: approved?, denied: denied?)

        redirect_to login.redirect_uri, allow_other_host: true
      elsif login.valid?
        render :continue
      elsif login.signup?
        render :signup
      elsif login.actor
        render :login
      else
        render :identify
      end
    end

    def consented?
      client.auto_consent? || (request.post? && params[:approve]) || login.already_complete?
    end

    def approved?
      !denied? && consented?
    end

    def denied?
      request.post? && params[:cancel]
    end

    def nickname_id
      return unless params[:nickname] && request.post? && params[:signup]

      profile.identifier(key: :nickname, value: params[:nickname])
    end

    def email_id
      return unless params[:email] && request.post? && params[:signup]

      profile.identifier(key: :email, value: params[:email])
    end

    def phone_id
      return unless params[:phone] && request.post? && params[:signup]

      profile.identifier(key: :phone, value: params[:phone])
    end

    # def signup
    #   # if password_param
    #   #   masks_session.verify!(actor, actor.valid_password?(password_param)) if actor
    #   # end

    #   # # if identifier_param
    #   # #   masks_session.verify!(actor, :identifier, identifier_param) if identified?
    #   # # end
    # end

    # def create
    #   # if signup?
    #   #   actor.password = password_param

    #   #   if actor.save
    #   #     login!
    #   #   else
    #   #     render :signup
    #   #   end

    #   #   return
    #   # end



    #   # if identifier_param
    #   #   masks_session.login_hint = identified? ? identifier_param : nil
    #   #   masks_session.verify!(actor, :identifier, identifier_param) if identified?
    #   # end

    #   # return render :identify unless identified? || signup?

    #   # if password_param && actor
    #   #   masks_session.verify!(actor, actor.valid_password?(password_param))
    #   # end

    #   # nil unless password_required?

    # end

    # def destroy
    # end

    private

    # def mask_params
    #   if request.post?
    #     params.slice(:login_hint) || {}
    #   else
    #     {}
    #   end
    # end

    # def identifier_param
    #   return unless profile.identifiers_enabled?

    #   login_hint
    # end

    # def password_param
    #   return unless profile.enabled?(:password) && request.post?

    #   params[:password]
    # end

    # def login_hint
    #   masks_session.login_hint || params[:login_hint]
    # end

    # def identifier
    #   @identifier ||= profile.identifier(value: identifier_param)
    # end

    # def identifiers_enabled?
    #   identifiers.keys.any? do |name|
    #     enabled?(name)
    #   end
    # end

    # def openid?
    #   false
    # end

    # def authorization

    # end

    # def actor
    #   @actor ||= find_actor || build_actor
    # end

    # def find_actor
    #   if identifier
    #     tenant.actors.includes(:identifiers).find_by(identifiers: { value: identifier.value, type: identifier.type })
    #   else
    #     masks_session.actor
    #   end
    # end

    # def build_actor
    #   return unless profile.enabled?(:signup)

    #   actor = Masks::Actor.new(tenant:)
    #   actor.password = password_param
    #   actor.identifiers << identifier if identifier
    #   actor.signup = true
    #   actor
    # end

    # def identified?
    #   actor && !actor.signup
    # end

    # def signup?
    #   profile.enabled?(:signup) && actor&.signup && actor.identifier&.valid?
    # end

    # def logged_in?
    #   identified? && valid_password? && valid_factor2? && actor.valid?
    # end

    # def signed_up?
    #   actor&.signup && valid_password?
    # end

    # def password_required?
    #   !masks_session.checked?(actor, :password)
    # end


    # def valid_password?

    # end

    # def accept_password
    #   return unless actor && session_params[:password]

    #   if actor.signup
    #     actor.password = session_params[:password]
    #   end

    #   masks_session.verify!(actor, :password, actor.authenticate(session_params[:password]))
    # end

    # def assign_masks
    #   @tenant = masks_tenant
    #   @profile = masks_profile
    # end

    # def session_request
    #   @session_request ||= Masks::SessionRequest.new(masks_request)
    # end

    # def openid_request?
    #   # masks_tenant.enabled?('openid')
    # end

    # def openid_client

    # end

    # def masks_profile
    #   if openid_request?
    #     openid_client.profile
    #   else
    #     masks_tenant.profile(params[:mask] || :session)
    #   end
    # end

    # def masks_profilers
    #   @masks_profilers ||= masks_profile.profilers.to_h do |cls|
    #     [cls.key, cls.new(self)]
    #   end
    # end

    # def actor
    #   actors.first if actors.length == 1
    # end

    # def actors
    #   @actors ||= begin
    #     actors = []

    #     masks_profilers.each_value do |c|
    #       actor = c.actor
    #       actors << actor if actor && !actors.include?(actor)
    #     end

    #     actors
    #   end
    # end

    # def actor_identified?
    #   if

    # end

    # def password_required?
    #   profile.enabled?('password') && !masks_request.passed?(:password)
    # end

    # def factor2_required?
    #   return false unless profile.enabled?('factor2')

    #   if identified? &&

    #   checks = @session.checks

    #   return false unless checks

    #   checks[:factor2] && !checks[:factor2]&.passed? &&
    #     checks[:actor]&.passed? && checks[:password]&.passed?
    # end

    # def signup?
    #   masks_settings['signups.enabled'] && @actor&.signup
    # end

    # def set_identifiers
    #   @identifier = masks_config.identifiers.keys.map do |field|
    #     masks_config.identifier?(field) ? field : nil
    #   end.compact.sort.join('_')
    # end

    # def resource_cls
    #   masks_config.model(:session_json)
    # end
  end
end
