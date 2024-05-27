# frozen_string_literal: true

module Masks
  module Sessions
    class Actors < ApplicationModel
      attribute :request
      attribute :tenant
      attribute :hint

      def any?
        all&.present?
      end

      def checked_value(key, actor: last_actor)
        return unless checked?(key, actor:)

        actor_data(actor).dig(key.to_s, "value")
      end

      def checked_time(key, actor: last_actor)
        return unless checked?(key, actor:)

        time = actor_data(actor).dig(key.to_s, "time")
        Time.parse(time) if time
      end

      def checked(key, value, actor: last_actor)
        actor_data(actor)[key.to_s] = if value
          { value:, time: Time.current.iso8601 }.stringify_keys
        end
      end

      def checked?(key, actor: last_actor)
        actor_data(actor).dig(key.to_s, "time").present? &&
          actor_data(actor).dig(key.to_s, "value").present?
      end

      def all
        @all ||=
          if data.keys.any?
            uuids = []

            data.each_value do |data|
              uuid = data.dig("actor", "value")
              uuids << uuid if uuid
            end

            tenant
              .actors
              .includes(:identifiers)
              .where(uuid: uuids.uniq.compact)
              .to_a
              .map do |actor|
                actor.last_login_at =
                  logged_in_at(actor) || checked_time("actor", actor:)
                actor
              end
              .sort_by(&:last_login_at)
          end
      end

      def last_actor
        @last_actor ||=
          if data.keys.any?
            actor = nil
            time = nil

            all.each do |alt|
              actor ||= alt
              time ||= logged_in_at(alt)
              alt_time = logged_in_at(alt)

              if alt_time && time && alt_time > time
                actor = alt
                time = alt_time
              end
            end

            actor
          end
      end

      def logged_in_at(actor)
        checked_time("redirect_uri", actor:)
      end

      def data
        request.session["#{tenant_key}:actors"] ||= {}
      end

      def actor_data(actor = self.actor)
        return @actor_data ||= {} unless actor

        data[actor.session_key] ||= {}
      end

      def tenant_key
        "masks:#{tenant.version}"
      end
    end
  end
end
