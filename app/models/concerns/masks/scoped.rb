# frozen_string_literal: true

module Masks
  module Scoped
    MANAGE = "masks:manage"
    PASSWORD = "masks:password"

    def masks_manager?
      scopes.include?(MANAGE)
    end

    def scopes
      super || []
    end

    def scope?(scope)
      scopes.include?(scope.to_s)
    end

    def scopes?(*scopes)
      scopes.all? { |scope| scope?(scope) }
    end

    def scopes_text=(text)
      self.scopes = text.split("\n").map { |line| line.split(" ") }.flatten

      sort_scopes!
    end

    def assign_scopes(*list)
      self.scopes += list
      sort_scopes!
    end

    def remove_scopes(*list)
      self.scopes -= list
      sort_scopes!
    end

    def sort_scopes!
      self.scopes = scopes.uniq.sort
    end
  end
end
