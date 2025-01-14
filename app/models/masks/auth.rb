module Masks
  class Auth < ApplicationModel
    APPROVED_PROMPTS = ["success"]

    include ActiveSupport::Callbacks

    define_callbacks :auth

    attribute :request
    attribute :session
    attribute :device
    attribute :device
    attribute :client
    attribute :auth_id
    attribute :identifier
    attribute :actor
    attribute :event
    attribute :updates
    attribute :prompt
    attribute :warnings
    attribute :login_link
    attribute :upload
    attribute :scopes
    attribute :error

    delegate :attempt_bag,
             :auth_bag,
             :actor_bag,
             :client_bag,
             :device_bag,
             :redirect_uri,
             :settled?,
             :settled!,
             :checked!,
             :checked?,
             :check,
             to: :state

    def begin!
    end

    def load!(id)
    end

    def state
      @state ||= Masks::State.new(auth: self)
    end

    def path
      state.attempt_bag&.fetch("path", nil)
    end

    def params
      state.attempt_bag&.fetch("params", nil)
    end

    def event?(name)
      event && event.to_s == name.to_s
    end

    def leak_actor?
      identifier && state.checked?("credentials")
    end

    def approved?
      settled? && state.settlement["approved"]
    end

    def manager
      prompt_for(Masks::Prompts::OIDC).manager
    end

    def resume!(id)
      state.resume!(id)

      run_callbacks(:auth)
    end

    def update!(id: nil, event: nil, upload: nil, updates: {}, resume: false)
      if resume
        state.resume!(id)

        self.event = event
        self.updates = updates || {}
        self.upload = upload
      else
        state.init!
      end

      run_callbacks(:auth) do
        return if settled?

        filtered = prompts.values.filter(&:enabled?)
        filtered.each { |prompt| prompt.event!(event) } if event
        filtered.each(&:prompt!)
      end
    rescue AuthError => e
      settled!(prompt: e.code, error: e.code)
    end

    def rails_session
      request.session
    end

    def id
      state&.attempt_id
    end

    def as_json
      @json ||= {
        id:,
        settled: settled?,
        trusted: trusted?,
        prompt: error || prompt || "identify",
        error:,
        client:,
        identifier:,
        providers: client&.providers,
        actor: leak_actor? ? actor : nil,
        avatar: actor&.avatar_url,
        identicon_id: actor&.identicon_id,
        login_link:,
        warnings:,
        extras:,
        scopes:,
        settings: install.public_settings,
      }.stringify_keys.merge(state.settlement || {}).symbolize_keys
    end

    def warnings
      @warnings ||= []
    end

    def warn!(*keys, prompt: nil)
      warnings << keys.compact.join(":")
      @warnings.uniq!
      self.prompt = prompt if prompt
      false
    end

    def extras(**additions)
      @extras ||= {}
      @extras.deep_merge!(additions)
      @extras
    end

    def trusted?
      return false if error || !actor&.persisted?

      if client.second_factor?
        checked?("credentials", "second-factor")
      else
        checked?("credentials")
      end
    end

    def authenticated?
      return false if error || !actor&.persisted?
      return false if prompt && APPROVED_PROMPTS.exclude?(prompt)

      checked?(*client.checks)
    end

    def prompt_for(cls)
      prompts.fetch(cls.to_s)
    end

    def install
      @install ||= Masks.installation.reload
    end

    private

    def prompts
      @prompts ||= Masks.prompts.map { |cls| [cls.to_s, cls.new(self)] }.to_h
    end
  end
end
