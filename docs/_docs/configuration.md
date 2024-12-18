---
category: guides
title: Configuration
description: how to configure masks
toc: true
order: -2
---

Although masks will boot without any configuration, you will likely need to
make some changes to suit your specific setup. Configuration can be supplied
using `ENV` variables and/or a `masks.yml` file.

## masks.yml

All of the settings outlined below can be overridden in your `masks.yml`. You
can view all of the defaults in the [masks source code](#).

{% capture masks_yml_info %}
<span>
<b class="text-warning">Note:</b> Most settings in your <code>masks.yml</code>
are only applied on initial setup. They will not override any changes made
after installation.
</span>
{% endcapture %}

{% include alert.html class="" content=masks_yml_info %}

## Environment variables

There are a few settings that are only controlled with environment variables:

| name            | description                   | default          |
| --------------- | ----------------------------- | ---------------- |
| `MASKS_YML`     | path to `masks.yml`           | /masks/masks.yml |
| `MASKS_PORT`    | port for the web server       | 5000             |
| `MASKS_THREADS` | number of threads per process | 1                |

---

## Minimal settings

At minimum, provide the name and public URL of your installation, along with
any settings required to access dependencies like the database.

| name     | ENV var        | default                |
| -------- | -------------- | ---------------------- |
| url      | `MASKS_URL`    | https://localhost:5000 |
| name     | `MASKS_NAME`   | masks                  |
| timezone | `MASKS_TZ`     | America/New_York       |
| region   | `MASKS_REGION` | US                     |

{% capture masks_yml_info %}
<span>
<b class="text-warning">Note</b> To change your installation url after
initial setup, change it in your <code>masks.yml</code> or with the
<code>MASKS_URL</code> var, then re-deploy. Cookies and devices will be
lost if the domain changes.
</span>
{% endcapture %}

{% include alert.html class="" content=masks_yml_info %}

### Database

The following database adapters are supported:

- PostgreSQL: `db.adapter=postgresql`
- SQLite: `db.adapter=sqlite3`

While a primary database is always required, you can use separate
databases for specific types of data: `queue`, `cache`, `websockets`,
and `sessions`.

| name                  | ENV var                       | default                                  |
| --------------------- | ----------------------------- | ---------------------------------------- |
| db.url                | `MASKS_DB_URL`                |                                          |
| db.adapter            | `MASKS_DB_ADAPTER`            | `sqlite3` unless specified via the `url` |
| db.name               | `MASKS_DB_NAME`               | `masks` or `data/masks.sqlite3`          |
| db.queue.url          | `MASKS_QUEUE_DB_URL`          |                                          |
| db.queue.adapter      | `MASKS_QUEUE_DB_ADAPTER`      |                                          |
| db.queue.name         | `MASKS_QUEUE_DB_NAME`         |                                          |
| db.cache.url          | `MASKS_CACHE_DB_URL`          |                                          |
| db.cache.adapter      | `MASKS_CACHE_DB_ADAPTER`      |                                          |
| db.cache.name         | `MASKS_CACHE_DB_NAME`         |                                          |
| db.websockets.url     | `MASKS_WEBSOCKETS_DB_URL`     |                                          |
| db.websockets.adapter | `MASKS_WEBSOCKETS_DB_ADAPTER` |                                          |
| db.websockets.name    | `MASKS_WEBSOCKETS_DB_NAME`    |                                          |
| db.sessions.url       | `MASKS_SESSIONS_DB_URL`       |                                          |
| db.sessions.adapter   | `MASKS_SESSIONS_DB_ADAPTER`   |                                          |
| db.sessions.name      | `MASKS_SESSIONS_DB_NAME`      |                                          |

{% capture sqlite_info%}
<span>
<b class="text-info">Note:"</b>
It's recommended to use separate databases if using SQLite or with
higher-traffic instances.
</span>
{% endcapture %}

{% include alert.html class="" content=sqlite_info %}

### Default data

The first time masks boots it will populate the database with default data, including:

- a [management client](clients.html#management-client)
- a default manager (if specified)
- any seed data found in `seeds`/`MASKS_SEEDS` directory
- settings, populated from `ENV` and `masks.yml`

| name             | ENV var                  | default |
| ---------------- | ------------------------ | ------- |
| seeds            | `MASKS_SEEDS`            |
| manager.nickname | `MASKS_MANAGER_NICKNAME` | manager |
| manager.password | `MASKS_MANAGER_PASSWORD` |
| manager.email    | `MASKS_MANAGER_EMAIL`    |

You can disable this behaviour with the `SKIP_MIGRATIONS` environment variable.

## Advanced settings

### Feature toggles

You can customize some of the features available to end-users depending on your use-case:

| name                   | default                |
| ---------------------- | ---------------------- |
| nicknames.enabled      | true                   |
| emails.enabled         | true                   |
| emails.max_for_login   | 5                      |
| passwords.min_chars    | 8                      |
| passwords.max_chars    | 100                    |
| passkeys.enabled       | true                   |
| login_links.enabled    | true                   |
| totp_codes.enabled     | true                   |
| phones.enabled         | true                   |
| webauthn.enabled       | true                   |
| webauthn.rp_name       | `name` or `MASKS_NAME` |
| backup_codes.min_chars | 8                      |
| backup_codes.max_chars | 100                    |
| backup_codes.total     | 10                     |

### Encryption

A `private_key`—stored on the filesystem—is used to encrypt and hash data
stored in masks. Additional keys are derived from the private key if they are
not supplied.

| name              | ENV var                   | default                    |
| ----------------- | ------------------------- | -------------------------- |
| private_key       | `MASKS_PRIVATE_KEY`       | ./data/private.key         |
| secret_key        | `MASKS_SECRET_KEY`        | _derived from private key_ |
| encryption_key    | `MASKS_ENCRYPTION_KEY`    | _derived from private key_ |
| deterministic_key | `MASKS_DETERMINISTIC_KEY` | _derived from private key_ |
| salt              | `MASKS_SALT`              | _derived from private key_ |

A private key will be created and saved automatically on first boot. If you're
using `docker compose`, make sure to store it on a local volume (along with
other masks data). For example:

```yml
# docker-compose.yml
services:
  masks:
    ...
    volumes:
      - /example/masks/data:/masks/data
```

### Theming

Masks can be customized with your organization's name, branding, and more.

| name                 | ENV var      | default |
| -------------------- | ------------ | ------- |
| theme.url            |              |         |
| theme.name           | `MASKS_NAME` | masks   |
| theme.light_logo_url |              |         |
| theme.dark_logo_url  |              |         |
| theme.favicon_url    |              |         |

Take a look at client configuration to customize the look and feel of client interactions.

### Clients

Take a look at the [guide to clients](clients.html#defaults) for information on
the default settings for clients. Like most configuration, you can set them in
your `masks.yml`.

## Integrations

There are several integrations with other services that expand Masks'
functionality. All settings for them are housed under the `integration` key in
`masks.yml`.

### Asset storage

Logos, avatars, and other uploads are stored on the local filesystem by default. You can
change the location or configure masks to store assets with a cloud
provider.

| name                                           | ENV var                            | default |
| ---------------------------------------------- | ---------------------------------- | ------- |
| integration.storage                            | `MASKS_STORAGE_INTEGRATION`        | disk    |
| integration.s3.access_key_id                   | `MASKS_S3_ACCESS_KEY_ID`           |
| integration.s3.secret_access_key               | `MASKS_S3_SECRET_ACCESS_KEY`       |
| integration.s3.region                          | `MASKS_S3_REGION`                  |
| integration.s3.bucket                          | `MASKS_S3_BUCKET`                  |
| integration.gcs.project                        | `MASKS_GCS_PROJECT`                |
| integration.gcs.credentials                    | `MASKS_GCS_CREDENTIALS`            |
| integration.gcs.bucket                         | `MASKS_GCS_BUCKET`                 |
| integration.azure_storage.storage_account_name | `MASKS_AZURE_STORAGE_ACCOUNT_NAME` |
| integration.azure_storage.storage_access_key   | `MASKS_AZURE_STORAGE_ACCESS_KEY`   |
| integration.azure_storage.container            | `MASKS_AZURE_STORAGE_CONTAINER`    |

### Email and phone

While masks can be used without sending email or SMS, it's recommended to
configure support for it. SMS & email verification, login links, and some
notifications depend on it.

| name                            | ENV var                     | default |
| ------------------------------- | --------------------------- | ------- |
| emails.from                     | `MASKS_EMAIL_FROM`          |
| emails.reply_to                 | `MASKS_EMAIL_REPLY_TO`      |
| integration.email               | `MASKS_EMAIL_INTEGRATION`   | smtp    |
| integration.phone               | `MASKS_PHONE_INTEGRATION`   | twilio  |
| integration.smtp.domain         | `MASKS_SMTP_DOMAIN`         |
| integration.smtp.address        | `MASKS_SMTP_ADDRESS`        |
| integration.smtp.port           | `MASKS_SMTP_PORT`           |
| integration.smtp.user_name      | `MASKS_SMTP_USER_NAME`      |
| integration.smtp.password       | `MASKS_SMTP_PASSWORD`       |
| integration.smtp.authentication | `MASKS_SMTP_AUTHENTICATION` |
| integration.twilio.account_sid  | `MASKS_TWILIO_ACCOUNT_SID`  |
| integration.twilio.auth_token   | `MASKS_TWILIO_AUTH_TOKEN`   |
| integration.twilio.service_sid  | `MASKS_TWILIO_SERVICE_SID`  |

### Monitoring

You can monitor a running masks instance with [Sentry](https://sentry.io).

| name                   | ENV var            | default |
| ---------------------- | ------------------ | ------- |
| integration.sentry.dsn | `MASKS_SENTRY_DSN` |
