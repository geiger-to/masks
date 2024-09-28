def log(str)
  puts "masks: #{str}"
end

ENV["MASKS_URL"] ||= "http://localhost:#{ENV.fetch("PORT", 5100)}"

Masks.install! do |installation|
  log "installing '#{installation.name}'..."

  if ENV["SEED_ADMIN"] || ENV["ADMIN_PASSWORD"]
    admin = Masks::Actor.new(nickname: "admin")
    admin.password = ENV["ADMIN_PASSWORD"] || SecureRandom.uuid
    admin.assign_scopes(Masks::Scoped::PASSWORD, Masks::Scoped::MANAGE)

    if admin.save
      log "creating 'admin' actor..."
      log(
        if ENV["ADMIN_PASSWORD"]
          "admin password set from ADMIN_PASSWORD env var"
        else
          "admin password is '#{admin.password}'"
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

  default =
    Masks::Client.new(
      client_type: "internal",
      name: Masks::Client::DEFAULT_KEY,
      scopes: [],
      redirect_uris: [ENV["MASKS_URL"] + "/"],
      consent: false,
    )

  if default.save
    log "created default client named '#{default.name}'."
  else
    log default.errors.full_messages.join("\n")
  end
end

def time_ago(time)
  ApplicationController.helpers.time_ago_in_words(time)
end

log "seeded #{time_ago(Masks::Installation.first.created_at)} ago..."
