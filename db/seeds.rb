def log(str)
  puts "masks: #{str}"
end

seeds = Masks.seed!

def time_ago(time)
  ApplicationController.helpers.time_ago_in_words(time)
end

log "imported #{seeds.stats[:imported]} record(s)" if seeds.stats[:imported]

if manager = seeds.stats[:manager]
  log "created manager with #{manager.map { |k, v| "#{k}=#{v}" }.join(" ")}"
end

if providers = seeds.stats[:providers]&.any?
  log "created providers: #{seeds.stats[:providers].map(&:name).join(", ")}"
end

log "created default client for managing masks..." if seeds.stats[:manage]

log "installed #{seeds.install.name} #{time_ago(seeds.install.created_at)} ago..."
