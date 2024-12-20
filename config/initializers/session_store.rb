Rails.application.config.after_initialize do
  Rails.application.config.session_store :active_record_store,
                                         key: "_masks",
                                         expire_after: Masks.lifetime(:session)
end

module Masks
  class SessionRecord < ActiveRecord::SessionStore::Session
    self.abstract_class = true

    if Masks.env.db_enabled?(:session)
      connects_to database: { writing: :sessions }
    end
  end

  class Session < SessionRecord
  end
end

ActionDispatch::Session::ActiveRecordStore.session_class = Masks::Session

# This cannot be overridden in Masks::Session, instead it must be here:
ActiveRecord::SessionStore::Session.table_name = "masks_sessions"
