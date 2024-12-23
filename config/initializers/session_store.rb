Rails.application.config.after_initialize do
  Rails.application.config.session_store :active_record_store,
                                         key: "_masks",
                                         expire_after: Masks::Session.cleanup_at

  ActionDispatch::Session::ActiveRecordStore.session_class = Masks::Session

  # This cannot be overridden in Masks::Session, instead it must be here:
  ActiveRecord::SessionStore::Session.table_name = "masks_sessions"
end
