module Masks
  class Seeds
    attr_reader :env, :install

    EXCLUDED = %w[
      schema_migrations
      ar_internal_metadata
      masks_devices
      masks_tokens
      masks_login_links
      masks_sessions
    ]

    def initialize(env)
      @env = env
    end

    def blob_dir
      @blob_dir ||= ensure_dir(dir.join("blobs"))
    end

    def dir
      @dir ||= env.seeds&.presence
    end

    def path
      dir.join("data.yml")
    end

    def stats
      @stats ||= reset_stats!
    end

    def reset_stats!
      @stats = { imported: 0, exported: 0 }
    end

    def actor!(nickname:, password:, scopes: nil, email: nil)
      actor = Masks::Actor.new(nickname:)

      if email.present?
        actor.emails.build(address: email, group: Masks::Email::LOGIN_GROUP)
      end

      actor.password = password
      actor.assign_scopes(*scopes)
      actor.save!
      actor
    end

    def manager!(**args)
      actor!(**args, scopes: [Masks::Scoped::OPENID, Masks::Scoped::MANAGE])
    end

    def client!(key:, name:, type:, logo: nil, **attrs)
      client = Masks::Client.create!(key:, name:, client_type: type, **attrs)

      blob!(client, :logo, logo) if logo

      client
    end

    def blob!(object, attachment, path)
      object.try(attachment).attach(
        io: File.open(Rails.root.join(path)),
        filename: path,
      )
    end

    def seed!
      @install ||= Masks.installation

      if !@install && !ENV["MASKS_SKIP_MIGRATIONS"]
        reset_stats!

        @install = Masks::Installation.create!(settings: @env)

        blob!(@install, :light_logo, "app/assets/images/masks.png")
        blob!(@install, :dark_logo, "app/assets/images/masks.png")
        blob!(@install, :favicon, "app/assets/images/masks.png")

        ensure_manager
        ensure_manage_client
        ensure_providers
      end

      @install
    end

    def export!
      reset_stats!

      export = {}

      # Iterate over each table in the database
      ActiveRecord::Base.connection.tables.each do |table|
        next if EXCLUDED.include?(table)

        # Fetch all records from the table
        records =
          ActiveRecord::Base.connection.select_all("SELECT * FROM ?", table)

        export[table] = records.each do |r|
          stats[:exported] += 1

          r.to_h
        end

        # Handle Active Storage blobs and attachments
        if table == "active_storage_blobs"
          records.each do |record|
            blob = ActiveStorage::Blob.find(record["id"])

            next unless blob.service.exist?(blob.key)

            # Save the blob file to the attachments directory
            File.open(blob_dir.join(blob.key), "wb") do |file|
              file.write(blob.download)
            end
          end
        end
      end

      File.open(path, "w") { |file| file.write(export.to_yaml) }

      self
    end

    def import!
      reset_stats!

      data = YAML.safe_load_file(path, permitted_classes: [Time])

      data.each do |table, records|
        next if EXCLUDED.include?(table)

        count =
          ActiveRecord::Base
            .connection
            .select_value("SELECT COUNT(*) FROM ?", table)
            .to_i

        if count.zero?
          records.each do |record|
            stats[:imported] += 1

            columns = record.keys.map { |col| "\"#{col}\"" }

            if table == "active_storage_blobs"
              file = File.join(blob_dir, record["key"])

              if File.exist?(file)
                blob = ActiveStorage::Blob.create!(**record.symbolize_keys)
                blob.upload(File.open(file))
              end
            else
              ActiveRecord::Base.connection.execute(
                ActiveRecord::Base.sanitize_sql_array(
                  [
                    "INSERT INTO #{table} (#{columns.join(",")}) VALUES (#{
                      record.keys.map { "?" }.join(", ")
                    })",
                    *record.values,
                  ],
                ),
              )
            end
          end
        end
      end

      self
    end

    private

    def ensure_dir(path)
      FileUtils.mkdir_p(path)
      path
    end

    def ensure_providers
      providers = @install.setting(:sso, :providers)
      providers.each do |key, attrs|
        attrs = { type: key, name: key.humanize, key: }.merge(
          attrs.deep_symbolize_keys,
        )
        cls = Masks::Provider::TYPE_MAP[attrs[:type]]

        next unless cls

        provider = cls.constantize.new(attrs.merge(type: cls))
        provider.save if provider.setup?

        stats[:providers] ||= []
        stats[:providers] << provider if provider.persisted?
      end
    end

    def ensure_manager
      manager = @install.setting(:manager).symbolize_keys

      if @install.manager? &&
           Masks.identify(manager[:nickname] || manager[:email]).new_record?
        manager!(**manager)

        stats[:manager] = manager.merge(password: "*hidden*")
      end
    end

    def ensure_manage_client
      unless Masks::Client.manage
        client =
          client!(
            type: "internal",
            key: Masks::Client::MANAGE_KEY,
            name: "Manage masks",
            scopes: {
              required: [Masks::Scoped::MANAGE],
            },
            redirect_uris: "/manage\n/manage*",
            fuzzy_redirect_uri: true,
          )

        stats[:manage] = client
      end
    end
  end
end
