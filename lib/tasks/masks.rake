def info(*args)
  puts ["masks:", *args].join(" ")
end

task :start, [:formation] do |t, args|
  sh("bin/rails db:prepare") unless ENV["SKIP_MIGRATIONS"]
  sh(["foreman", "start", args[:formation]].compact.join(" "))
end

task worker: :environment do
  case Rails.application.config.active_job.queue_adapter
  when :sidekiq
    sh "bin/bundle exec sidekiq"
  when :good_job
    sh "bin/bundle exec good_job start"
  when :delayed_job
    sh "bin/rails jobs:work"
  end
end

task :migrate do |t, args|
  sh "bin/rails db:migrate"
end

namespace :seeds do
  task export: :environment do
    info "creating export..."

    seeds = Masks.installation.seeds
    seeds.export!

    info "saved #{seeds.stats[:exported]} records to '#{seeds.path}'"
  end

  task import: :environment do
    seeds = Masks.installation.seeds

    info "importing from '#{seeds.path}'"

    seeds.import!

    info "imported #{seeds.stats[:imported]} records"
  end
end
