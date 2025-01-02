Rails.application.config.session_store :active_record_store, key: "_masks"

Rails.application.config.to_prepare do
  Rails.application.config.session_options[
    :expire_after
  ] = Masks::Session.expire_after if Masks::Session.expire_after

  # Use the custom session class for consistency, though both should work.
  ActionDispatch::Session::ActiveRecordStore.session_class = Masks::Session

  # This cannot be overridden in Masks::Session, instead it must be here:
  ActiveRecord::SessionStore::Session.table_name = "masks_sessions"
end
