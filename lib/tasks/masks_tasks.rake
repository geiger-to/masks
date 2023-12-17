# frozen_string_literal: true

def cli_access(access_name, **opts)
  access = nil
  actor = opts.delete(:as) || ENV["ACTOR"] || Masks::ANON

  Masks.mask("cli", as: actor, **opts) do |session|
    access = session.access(access_name)
  end

  access
end

namespace :masks do
  task boot: :environment do
    # required to ensure access classes (and others) are registered properly
    Rails.application.eager_load!
  end

  task :signup, %i[nickname password] => :boot do |_task, args|
    access = cli_access("actor.signup", args:)
    signup = access.signup(**args) if access

    if !access
      puts "could not find actor..."
    elsif signup.invalid?
      puts "failed to signup '#{signup.nickname}'"
      puts "error: #{signup.errors.full_messages.join(", ")}"
    else
      puts "created '#{signup.nickname}'!"
    end
  end

  task :assign_scopes, %i[actor scopes] => :boot do |_task, args|
    if !args[:actor] || !args[:scopes]
      puts "specify an actor and scopes, e.g. masks:assign_scopes[@foo,scope1;scope2;scope3]"
      exit 1
    end

    access = cli_access("actor.scopes", as: args[:actor])
    access&.assign_scopes(args[:scopes].split(";"))

    if !access
      puts "could not find actor..."
    elsif access.actor.invalid?
      puts "failed to assign scopes to '#{access.actor.nickname}'"
      puts "error: #{access.actor.errors.full_messages.join(", ")}"
    else
      puts "assigned scopes to '#{access.actor.nickname}'"
    end
  end

  task :change_password, %i[actor password] => :boot do |_task, args|
    if !args[:actor] || !args[:password]
      puts "specify an actor and password, e.g. masks:change_password[@foo,password]"
      exit 1
    end

    access = cli_access("actor.password", as: args[:actor])
    access&.change_password(args[:password])

    if !access
      puts "could not find actor..."
    elsif access.actor.invalid?
      puts "failed to change password for '#{access.actor.nickname}'"
      puts "error: #{access.actor.errors.full_messages.join(", ")}"
    else
      puts "changed password for '#{access.actor.nickname}'"
    end
  end
end
