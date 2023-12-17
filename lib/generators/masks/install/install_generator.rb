class Masks::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def add_routing
    route 'mount Masks::Engine => "/"'
  end

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/masks.rb"
  end

  def copy_masks_json
    copy_file "masks.json", "masks.json"
  end

  def add_migrations
    if yes?("generate migrations for masks?")
      rails_command "masks:install:migrations"
    else
      puts
      puts 'run "rails masks:install:migrations" to add them later on...'
    end

    puts
    puts "[masks] - getting started"
    puts "the default installation requires authentication for every endpoint in your Rails app."
    puts "visit 'https://masks.geiger.to/get-started' for documentation."
  end
end
