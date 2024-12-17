Rails.application.config.after_initialize do
  if Masks.env.db_enabled?(:cache)
    SolidCache::Record.connects_to database: { writing: :cache }
  end
end
