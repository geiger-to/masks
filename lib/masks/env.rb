module Masks
  class Env < RecursiveOpenStruct
    def queue_adapter
      if redis.url.present?
        :sidekiq
      elsif db_adapter == "postgresql"
        :good_job
      else
        :delayed_job
      end
    end
    def db_adapter
      @db_adapter ||=
        begin
          adapter = db.adapter&.presence
          adapter ||= adapter_from_url(db.url&.split(":")&.first)
          adapter ||= "sqlite3" unless db.url.present?
          adapter
        end
    end

    def db_name
      return db.name if db.name&.present?

      return if db.url&.present?

      if db_adapter == "sqlite3"
        "data/#{Rails.env}"
      else
        "masks_#{Rails.env}"
      end
    end

    private

    def adapter_from_url(value)
      return unless value&.present?

      value.start_with?("postgres") ? "postgresql" : "sqlite3"
    end
  end
end
