module Masks
  class Auth < ApplicationModel
    include ActiveSupport::Callbacks

    define_callbacks :update

    attribute :updated
    attribute :request
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

    delegate :session, to: :request
    delegate :attempt_bag,
             :auth_bag,
             :actor_bag,
             :id_bag,
             :redirect_uri,
             :settled!,
             :checked!,
             :checked?,
             :check,
             to: :state

    def state
      @state ||= Masks::State.new(auth: self)
    end

    def path
      state.attempt_bag&.fetch(:path, nil)
    end

    def params
      state.attempt_bag&.fetch(:params, nil)
    end

    def event?(name)
      event && event.to_s == name.to_s
    end

    def leak_actor?
      identifier && state.checked?("credentials")
    end

    def settled?
      !!(error || state.settled?)
    end

    def update!(id: nil, event: nil, upload: nil, updates: {}, resume: false)
      return updated if updated

      self.updated = true

      raise InvalidPromptError unless prompts.any?

      if resume
        state.resume!(id)

        self.event = event
        self.updates = updates || {}
        self.upload = upload
      else
        state.init!
      end

      run_callbacks(:update) do
        filtered = prompts.values.filter(&:enabled?)
        filtered.each { |prompt| prompt.event!(event) } if event
        filtered.each(&:prompt!)
      end
    rescue AuthError => e
      self.prompt = e.code
      self.error = e.code
    end

    def rails_session
      request.session
    end

    def as_json
      @json ||= {
        id: state.attempt_id,
        settled: settled?,
        prompt: error || prompt || "identify",
        error:,
        client:,
        identifier:,
        actor: leak_actor? ? actor : nil,
        avatar: actor&.avatar_url,
        identicon_id: actor&.identicon_id,
        login_link:,
        warnings:,
        extras:,
        scopes:,
        settings: Masks.installation.public_settings,
      }.merge(state.settlement || {})
    end

    def warnings
      @warnings ||= []
    end

    def warn!(*keys, prompt: nil)
      warnings << keys.compact.join(":")
      @warnings.uniq!
      self.prompt = prompt if prompt
    end

    def extras(**additions)
      @extras ||= {}
      @extras.deep_merge!(additions)
      @extras
    end

    def authenticated?
      if !error && !prompt && actor&.persisted? && client.checks&.any?
        return checked?(*client.checks)
      end

      false
    end

    def prompt_for(cls)
      prompts.fetch(cls.to_s)
    end

    private

    def prompts
      return [] unless updated

      @prompts ||= Masks.prompts.map { |cls| [cls.to_s, cls.new(self)] }.to_h
    end
  end
end
