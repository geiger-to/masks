module Masks
  class SessionRecord < ActiveRecord::SessionStore::Session
    self.abstract_class = true

    if Masks.env.db_enabled?(:session)
      connects_to database: { writing: :sessions }
    end
  end

  class Session < SessionRecord
    include Cleanable

    cleanup :updated_at do
      Masks.installation&.duration(:sessions, :inactive)
    end

    class << self
      def expire_after
        Masks.installation&.duration(:sessions, :lifetime)
      end
    end
  end
end
