module Masks
  class Env < RecursiveOpenStruct
    PRIMARY_DB_TYPE = "primary"
    DEFAULT_DB_ADAPTER = "sqlite3"

    def db_enabled?(type)
      return true if type.to_s == PRIMARY_DB_TYPE

      db[type]&.url&.present? || db[type]&.adapter&.present?
    end

    def multiple_dbs?
      %w[queue cache sessions websockets].any? { |type| db_enabled?(type) }
    end

    def db_adapter(type)
      return unless db_enabled?(type)

      config = primary_type?(type) ? db : db[type]
      adapter = config&.adapter&.presence
      adapter ||= adapter_from_url(config&.url)
      adapter ||= DEFAULT_DB_ADAPTER
      adapter
    end

    def db_name(type)
      return unless db_enabled?(type)

      config = primary_type?(type) ? db : db[type]

      return config.name if config.name&.present?

      env = Rails.env.production? ? nil : Rails.env
      name = primary_type?(type) ? "masks" : type

      if db_adapter(type) == "sqlite3"
        "data/#{[env, name].compact.join(".").presence || "masks"}.sqlite3"
      else
        ["masks", name == "masks" ? env : ([env, name])].flatten.compact.join(
          "_",
        )
      end
    end

    private

    def adapter_from_url(value)
      return unless value&.present?

      value.start_with?("postgres") ? "postgresql" : "sqlite3"
    end

    def primary_type?(type)
      type.to_s == PRIMARY_DB_TYPE
    end
  end
end
