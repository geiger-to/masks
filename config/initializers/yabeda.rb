if Masks.env.queue_adapter == :sidekiq
  Sidekiq.configure_server { |_config| Yabeda::ActiveJob.install! }
else
  Yabeda::ActiveJob.install!
end
