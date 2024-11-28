def log(str)
  puts "masks: #{str}"
end

ENV["MASKS_URL"] ||= "http://localhost:#{ENV.fetch("PORT", 1111)}"

Masks.install! do |install|
  log "installing '#{install.name}'..."

  seeder = Masks::Seeder.new(install)
  seeder.seed_env!

  log "installation complete."

  exit 0
end

def time_ago(time)
  ApplicationController.helpers.time_ago_in_words(time)
end

log "seeded #{time_ago(Masks::Installation.first.created_at)} ago..."
