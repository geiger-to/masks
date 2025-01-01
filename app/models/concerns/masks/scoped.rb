# frozen_string_literal: true

module Masks
  module Scoped
    OPENID = "openid"
    MANAGE = "masks:manage"
    PASSWORD = "masks:password"

    def openid?
      scope?(OPENID)
    end

    def masks_manager?
      scope?(MANAGE)
    end

    def scopes
      super&.strip || ""
    rescue NoMethodError
      self[:scopes]&.strip || ""
    end

    def scopes_a
      scopes
        .split("\n")
        .map { |line| line.split(" ") }
        .flatten
        .compact
        .uniq
        .sort
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
