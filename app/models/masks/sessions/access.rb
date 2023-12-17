module Masks
  module Sessions
    class Access < Masks::Session
      attribute :name
      attribute :original

      delegate :config, :params, :data, :writable?, to: :original

      def matches_mask?(mask)
        return unless mask.access

        if mask.access.include?(name.to_s) && original.mask&.type == mask.type
          return true
        end
      end
    end
  end
end
