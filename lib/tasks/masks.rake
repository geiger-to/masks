def info(*args)
  puts ["masks:", *args].join(" ")
end

namespace :masks do
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

  task jobs: :environment do
    case Rails.application.config.active_job.queue_adapter
    when :sidekiq
      sh "bin/bundle exec sidekiq"
    when :good_job
      sh "bin/bundle exec good_job start"
    when :delayed_job
      sh "bin/rails jobs:work"
    end
  end
end
