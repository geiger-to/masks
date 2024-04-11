# frozen_string_literal: true

module Masks
  module Sessions
    # Session for masking access classes.
    class Access < Masks::Session
      attribute :name
      attribute :original

      delegate :actor,
               :config,
               :params,
               :data,
               :writable?,
               :extras,
               :extra,
               to: :original

      def matches_mask?(mask)
        return false unless mask.access == name.to_s

        original.mask.access&.try(:include?, name.to_s) ||
          original.mask.access == mask.access
      end
    end
  end
end
