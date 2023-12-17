module Masks
  module Sessions
    # Session for masking inline ruby code.
    class Inline < Masks::Session
      attribute :name
      attribute :data
      attribute :params

      def matches_mask?(mask)
        return true if mask.name == name
      end
    end
  end
end
