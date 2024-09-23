def log(str)
  puts "masks: #{str}"
end

Masks.install! do |installation|
  log "installing '#{installation.name}'..."

  if ENV["SEED_ADMIN"]
    admin = Masks::Actor.new(nickname: "admin")
    admin.password = SecureRandom.uuid

    if admin.save
      log "creating 'admin' because 'SEED_ADMIN' is truthy..."
      log "admin password is '#{admin.password}'"
    end
  end
end

def time_ago(time)
  ApplicationController.helpers.time_ago_in_words(time)
end

log "seeded #{time_ago(Masks::Installation.first.created_at)} ago..."
