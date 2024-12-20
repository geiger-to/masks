module Masks
  class ManagerConstraint
    def matches?(request)
      Masks::Auth.new(request:).manager&.present?
    end
  end
end
