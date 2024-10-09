# frozen_string_literal: true

module Masks
  module Scoped
    MANAGE = "masks:manage"
    PASSWORD = "masks:password"

    def scopes
      super&.strip || ""
    end

    def masks_manager?
      scopes.include?(MANAGE)
    end

    def scopes_a
      scopes.split("\n").map { |line| line.split(" ") }.flatten.compact
    end

    def scope?(scope)
      scopes_a.include?(scope.to_s)
    end

    def scopes?(*scopes)
      scopes.all? { |scope| scope?(scope) }
    end

    def assign_scopes(*list)
      self.scopes += "#{list.join(" ")}\n"
    end

    def remove_scopes(*list)
      list.each { |item| self.scopes.gsub!(item, "") }
    end
  end
end
