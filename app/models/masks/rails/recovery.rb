# frozen_string_literal: true

module Masks
  module Rails
    class Recovery < ApplicationRecord
      self.table_name = "recoveries"

      scope :recent,
            lambda {
              where(
                "created_at >= ?",
                Masks.configuration.lifetimes[:recovery_email]&.ago ||
                  1.hour.ago
              )
            }
      scope :expired,
            lambda {
              where(
                "created_at < ?",
                Masks.configuration.lifetimes[:recovery_email]&.ago ||
                  1.hour.ago
              )
            }

      belongs_to :actor, class_name: Masks.configuration.models[:actor]

      validates :token, presence: true, uniqueness: { scope: :actor_id }
      validates :contact, presence: true, if: :actor
      validate :validates_actor

      attribute :configuration
      attribute :session
      attribute :value

      after_initialize :generate_token
      after_initialize :load_actor, unless: :actor_id

      def to
        case contact
        when Email
          contact.email
        end
      end

      def notified?
        notified_at.present?
      end

      def reset_password!(password)
        return unless actor && persisted?

        actor.password = password

        return unless actor.valid?

        actor.save!
        destroy!
      end

      def notify!
        return if !valid? || notified?

        self.notified_at = Time.current
        save!

        case contact
        when Email
          ActorMailer.with(recovery: id).recover_credentials.deliver_later
        end
      end

      def contact
        return unless actor

        @contact ||=
          begin
            contact =
              if email
                actor.emails.find_by(verified: true, email:)
              elsif phone
                # TODO
              end

            contact ||= actor.emails.where(verified: true).first
            contact
          end
      end

      def to_param
        token
      end

      private

      def generate_token
        self.token ||= SecureRandom.hex(64)
      end

      def validates_actor
        return if !actor || actor.valid?

        actor.errors.full_messages.each { |error| errors.add(:base, error) }
      end

      def load_actor
        return unless value

        loaded =
          self.actor = configuration.find_actor(session, email:, nickname:)

        loaded.recoveries << self if loaded
        loaded
      end
    end
  end
end
