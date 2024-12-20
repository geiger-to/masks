Rails.application.config.after_initialize do
  Masks.installation&.reconfigured_at = nil
  Masks.installation&.save!
end
