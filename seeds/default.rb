# frozen_string_literal: true
Masks::Seeder.run do
  seed_tenant("default") do |tenant|
    tenant.settings =
      tenant.settings.merge(
        nickname: {
          prefix: "@",
          enabled: true,
          signups: true,
          minimum: "4",
          maximum: "16"
        },
        email: {
          enabled: true,
          signups: false
        },
        phone: {
          enabled: true,
          signups: false
        }
      )

    default =
      seed_profile(tenant, "default") do |profile|
        profile.defaulted_at = Time.current
      end

    seed_actor(default, "admin", password: "password") do |admin|
      admin.assign_scopes("openid", "email", "masks:manage")
    end

    seed_actor(default, "test1", password: "password")
    seed_actor(default, "test2", password: "password")
    seed_actor(default, "test3", password: "password")

    tenant.client =
      if (client_key = tenant.setting(:client))
        seed_client(
          default,
          client_key,
          name: tenant.name,
          client_type: "internal",
          scopes: %w[masks:profile],
          redirect_uris: [tenant.redirect_uri, "#{tenant.redirect_uri}*"],
          consent: true,
          profile: default
        )
      end

    tenant.admin =
      if (admin_key = tenant.setting(:admin))
        seed_client(
          default,
          admin_key,
          name: "#{tenant.name} admin",
          client_type: "confidential",
          redirect_uris: [tenant.redirect_uri, "#{tenant.redirect_uri}*"],
          scopes: %w[openid email masks:manage],
          consent: false,
          profile: default
        )
      end
  end

  # seed_tenant('development', 'masks/seeds/example.tenant')
end

# X-Masks-Tenant <tenant-id>
# <tenant-id>.example.com
# example.com/<tenant-id>
#
# All tenants expose the following API:
#
# GET /session -> accepts OpenID/OAuth requests and normal logins
# POST /session -> creates (or continues) a session
# DELETE /session -> ends a session (identified by cookies or otherwise)
#
# /my - Actor API
# /manage - Management API
# /token - Token API (OAuth)
# /client - Client API (OpenID)
# /userinfo - Userinfo API (OpenID)
