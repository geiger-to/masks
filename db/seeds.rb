def log(str)
  puts "masks: #{str}"
end

ENV["MASKS_URL"] ||= "http://localhost:#{ENV.fetch("PORT", 1111)}"

Masks.install! do |installation|
  log "installing '#{installation.name}'..."

  if ENV["SEED_MANAGER"] || ENV["MANAGER_PASSWORD"]
    manager = Masks::Actor.new(nickname: "manager")
    manager.password = ENV["MANAGER_PASSWORD"] || SecureRandom.uuid
    manager.assign_scopes(Masks::Scoped::PASSWORD, Masks::Scoped::MANAGE)

    if manager.save
      log "creating 'manager' actor..."
      log(
        if ENV["MANAGER_PASSWORD"]
          "manager password set from MANAGER_PASSWORD env var"
        else
          "manager password is '#{manager.password}'"
        end,
      )
    end
  end

  manage =
    Masks::Client.new(
      client_type: "internal",
      key: Masks::Client::MANAGE_KEY,
      name: "manage masks",
      scopes: [Masks::Scoped::MANAGE],
      redirect_uris: [ENV["MASKS_URL"] + "/manage"],
      consent: false,
    )

  if manage.save
    log "created management client named '#{manage.name}'."
  else
    log manage.errors.full_messages.join("\n")
  end
end

def time_ago(time)
  ApplicationController.helpers.time_ago_in_words(time)
end

log "seeded #{time_ago(Masks::Installation.first.created_at)} ago..."
