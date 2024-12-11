module Masks
  class ClientScope
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def minimum(scope)
      (ensure_array(scope) + required).uniq
    end

    def required
      client.scopes&.dig("required") || []
    end

    def all
      (required + (client.scopes&.dig("allowed") || [])).uniq
    end

    private

    def ensure_array(scope)
      case scope
      when String
        scope.split(" ")
      when Array
        scope
      when nil
        []
      else
        raise "unknown scope type"
      end
    end
  end
end
