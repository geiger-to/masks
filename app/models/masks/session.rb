# frozen_string_literal: true

module Masks
  # Interface for sessions, which keep track of attempts to access resources.
  #
  # The helper methods provided by the +Masks+ module are wrappers around
  # the +Masks::Session+ class. Masks creates different types of sessions
  # dependending on the context, calls their +mask!+ method, and records
  # the results.
  #
  # This class is designed to be sub-classed. Sub-classes must provide a +data+,
  # +params+, and +matches_mask?+ method. The latter method is how a session
  # is able to find a suitable mask from the configuration.
  #
  # After a session's +mask!+ method is called, it will report an +actor+,
  # whether or not the checks it ran have +passed?+, and any +errors+ (just like
  # an +ActiveRecord+ model).
  #
  # @see Masks::Check Masks::Check
  # @see Masks::Credentials Masks::Credentials
  # @see Masks::Sessions Masks::Sessions
  # @see Masks::Mask Masks::Mask
  class Session < ApplicationModel
    attribute :request

    def initialize(request)
      super(request:)
    end

    def tenant_id
      @tenant_id ||= Masks.configuration.data.dig(:tenants, :default)
    end

    def tenant
      @tenant ||= Masks::Tenant.find_by!(key: tenant_id)
    end

    def login_hint=(hint)
      current_data[:login_hint] = hint
    end

    def actor=(actor)
      if current_data[:actor_id] && current_data[:actor_id] != actor.uuid
        add_alt(current_data[:actor_id])
      end

      current_data[:actor_id] = actor.uuid
    end

    def actor
      @actor ||=
        if current_data[:actor_id]
          Masks::Actor.find_by(uuid: current_data[:actor_id])
        end
    end

    def add_alt(id)
      current_data[:alts] ||= []

      return if current_data[:alts].include?(id)

      current_data[:alts] << id
    end

    def alt_actors
      @alt_actors ||=
        current_data
          .fetch(:alts, [])
          .map { |uuid| Masks::Actor.find_by(uuid:) }
          .compact
    end

    def checked(key, approved)
      return unless actor && !actor.new_record?

      current_data[actor.uuid] ||= {}
      current_data[actor.uuid][key] = approved ? Time.current.iso8601 : nil
    end

    def checked?(key)
      return unless actor && !actor.new_record?

      current_data[actor.uuid] ||= {}
      current_data[actor.uuid][key]
    end

    def current_data
      request.session[:masks] ||= {}
      request.session[:masks][tenant.key] ||= {}
    end
  end
end
