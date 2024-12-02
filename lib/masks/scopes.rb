module Masks
  class Scopes
    def detail(name)
      data = get(name)

      case data
      when String
        data
      when Hash
        data["detail"]
      else
        nil
      end
    end

    def hidden?(name)
      case get(name)
      when Hash
        !!data["hidden"]
      else
        false
      end
    end

    def get(name)
      config&.fetch(name.to_s, nil)
    end

    private

    def config
      @config ||=
        Rails.application.config_for("scopes").to_h.deep_stringify_keys
    end
  end
end
