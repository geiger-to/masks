if dsn = Masks.env.integration&.sentry&.dsn
  Sentry.init do |config|
    config.dsn = dsn
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.traces_sample_rate = 1.0
    config.profiles_sample_rate = 1.0
    config.enabled_patches << :graphql
  end
end
