module Masks
  class State < ApplicationModel
    attribute :attempt_id
    attribute :auth

    delegate :rails_session,
             :request,
             :client,
             :client=,
             :device,
             :actor,
             :identifier,
             to: :auth

    def [](key)
      @current ||= {}
      @current[key.to_s]
    end

    def []=(key, value)
      @current ||= {}
      @current[key.to_s] = value
    end

    def redirect_uri
      attempt_bag&.dig("settlement", "redirect_uri")
    end

    def approved?
      self[:approved]
    end

    def settled!(prompt:, redirect_uri: nil, error: nil, approved: false)
      auth.prompt = prompt if prompt
      auth.error = error if error

      self[:approved] = approved

      return unless attempt_bag

      attempt_bag["settlement"] = {
        "settled" => true,
        "prompt" => prompt,
        "identifier" => identifier,
        "redirect_uri" => redirect_uri,
        "approved" => approved,
        "error" => error,
      }
    end

    def settlement
      attempt_bag&.dig("settlement") if settled?
    end

    def settled?
      attempt_bag&.dig("settlement")&.present?
    end

    def check(name)
      @checks ||= {}
      @checks[Masks::Checks.to_name(name)] ||= Masks::Checks.to_cls(name).new(
        state: self,
      )
    end

    def checked!(name, **args)
      check(name).checked!(**args)
    end

    def checking?(name)
      return false unless client

      current = client.checks.find { |c| !check(c).checked? }

      return false unless current

      Masks::Checks.to_name(name) == Masks::Checks.to_name(current)
    end

    def checked?(*names, except: nil)
      names =
        if except
          except = Array(except).map { |name| Masks::Checks.to_name(name) }

          (names.any? ? names : client.checks) - except
        else
          Masks::Checks.names(client.checks) & Masks::Checks.names(names)
        end

      names.any? ? names.all? { |name| check(name).checked? } : false
    end

    def init!
      raise MissingClientError unless client

      query = params.sort_by { |k, _| k.to_s }.to_h.to_query
      id = Digest::SHA256.hexdigest(query)

      self.attempt_id = id

      validate_state!
    rescue ExpiredStateError
      reset_attempt!
    end

    def resume!(id)
      self.attempt_id ||= id
      self.client =
        if id = attempt_bag&.dig("client_id")
          Masks::Client.find_by(id:)
        end

      validate_state!
    rescue ExpiredStateError => e
      if attempt_id && attempts_bag&.dig(attempt_id, "settlement")
        attempts_bag[attempt_id]["settlement"] = nil
      end

      raise
    end

    def id_bag
      identifiers_bag[identifier] ||= {} if identifier
    end

    def attempt_bag
      attempts_bag[attempt_id] if attempt_id
    end

    def actor_bag
      actors_bag[actor.session_key] ||= {} if actor&.persisted?
    end

    def auth_bag
      attempt_bag["auth"] ||= {}
      attempt_bag["auth"][identifier] ||= {} if identifier && attempt_bag
    end

    def client_bag(client = nil)
      client ||= self.client

      return unless client

      rails_session["clients"] ||= {}
      rails_session["clients"][client.key] ||= {}
    end

    def reset!(error = nil)
      rails_session["identifiers"] = {}
      rails_session["attempts"] = {}
      rails_session["actors"] = {}
      rails_session["clients"] = {}

      reset_attempt!

      raise error if error
    end

    def reset_attempt!
      attempts_bag[attempt_id] = {
        "expires_at" => client.expires_at(:auth_attempt).iso8601,
        "client_id" => client.id,
        "path" => request.path,
        "params" => params,
      } if attempt_id
    end

    private

    def params
      client&.authorize_params(
        request
          .params
          .slice(
            *%w[
              client_id
              response_type
              grant_type
              redirect_uri
              scope
              state
              nonce
            ],
          )
          .symbolize_keys,
      )
    end

    def checks_bag
      if actor_bag
        actor_bag["checks"] ||= {}
      elsif id_bag
        id_bag["checks"] ||= {}
      else
        @checks_bag ||= {}
      end
    end

    def identifiers_bag
      rails_session["identifiers"] ||= {}
    end

    def attempts_bag
      rails_session["attempts"] ||= {}
    end

    def actors_bag
      rails_session["actors"] ||= {}
    end

    def validate_state!
      raise MissingClientError unless client

      if Masks.time.expired?(attempt_bag&.dig("expires_at"))
        raise ExpiredStateError
      end

      raise MissingStateError unless attempt_id && attempt_bag

      unless attempt_bag["client_id"] && client&.id == attempt_bag["client_id"]
        reset! MismatchedClientError
      end
    end
  end
end
