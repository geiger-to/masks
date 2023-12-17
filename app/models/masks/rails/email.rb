# frozen_string_literal: true

module Masks
  module Rails
    class Email < ApplicationRecord
      self.table_name = "emails"

      belongs_to :actor, class_name: Masks.configuration.models[:actor]

      validates :token, presence: true, uniqueness: true
      validates :email, presence: true, email: true
      validates :expired?, absence: true

      validate :validates_verified_email

      after_initialize :generate_token
      before_validation :downcase_email

      def notify!(session)
        return if verified?

        if expired? && !verified?
          self.notified_at = nil
          self.token = nil

          generate_token
        end

        return if notified?

        self.notified_at = Time.current

        return unless valid?

        save
        ActorMailer.with(session:, email: self).verify_email.deliver_now
      end

      def verify!
        return if verified?

        self.verified_at = Time.current
        self.verified = true
        save!
      end

      def to_param
        token
      end

      def notified?
        notified_at.present?
      end

      def expired?
        return false unless notified?

        notified_at <=
          (Masks.configuration.lifetimes[:verification_email] || 1.hour).ago
      end

      def taken?
        self.class.where(email:, verified: true).any?
      end

      private

      def validates_verified_email
        # not sure how to check this with uniqueness conditions,
        # so using a custom validation
        query =
          self.class.where(
            [
              persisted? ? "id != :id AND (" : "(",
              "(email = :email AND verified) OR",
              "(actor_id = :actor_id AND email = :email)",
              ")"
            ].compact.join(" "),
            actor_id: actor.id,
            email: email.downcase,
            id:
          )

        errors.add(:email, :taken) if query.any?
      end

      def generate_token
        self.token ||= SecureRandom.hex
      end

      def downcase_email
        self.email = email&.downcase
      end
    end
  end
end
