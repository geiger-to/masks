---
category: guides
title: Configuration
description: how to configure masks
toc: true
---

You can run masks as a standalone container or inside your Rails app. Either
way, masks expects at least some of the following to run properly:

- A `PostgreSQL`, `SQLite`, or `MySQL` database
- `SMTP` credentials or a working `sendmail` for email
- Disk-space or an `S3` bucket for avatar storage
- A reasonably fast `Linux` or `MacOS` machine
- An optional `redis` for caching and queuing

## Docker

### [`docker.io/geigerto/masks`](https://hub.docker.com/r/geigerto/masks)

Take a look at the sample `compose.yml` files for examples.

### Environment variables

The following environment variables _must_ be set:

#### `PORT` 1111

#### `MASKS_URL` http://localhost:1111

#### `MASKS_DATABASE_URL` sqlite3://db/production.sqlite

#### `MASKS_KEY`

The rest are optional:

#### `MASKS_ENCRYPTION_KEY`

#### `MASKS_DETERMINISTIC_KEY`

#### `MASKS_SALT`

#### `MASKS_STORAGE` disk

#### `MASKS_STORAGE_DIR` ./storage

#### `MASKS_LOG_LEVEL` info

#### `MASKS_AWS_BUCKET`

#### `MASKS_AWS_KEY_ID`

#### `MASKS_AWS_SECRET`

#### `MASKS_GCS_PROJECT`

#### `MASKS_GCS_BUCKET`

#### `MASKS_GCS_KEYFILE`

#### `MASKS_AZURE_ACCOUNT`

#### `MASKS_AZURE_KEY`

#### `MASKS_AZURE_CONTAINER`

#### `MASKS_SENDMAIL`

#### `MASKS_SMTP_ADDRESS`

#### `MASKS_SMTP_USER_NAME`

#### `MASKS_SMTP_PASSWORD`

#### `MASKS_SMTP_PORT`

#### `MASKS_SMTP_DOMAIN`

#### `MASKS_SMTP_MODE`

### Container

```
version: "3"

services:
  masks:
    image: docker.io/masks/masks:latest
    volumes:
      - /path/to/data:/masks/storage
      - /path/to/db:/masks/db
    restart: "unless-stopped"
    environment:
      MASKS_URL: https://masks.example.com
      MASKS_KEY: secret
    ports:
      - "1111:1111"
```

## Rails engine

When installed as a Rails engine masks can be configured using
a `config/masks.yml` file. Anything found in this file will
be
ruby and an initiailizer:

```ruby
# config/initializers/masks.rb
Masks.configure do |masks|
  masks.url =
end
```

## Web-based

After installation, much of masks can be configured using its
web-based management interface. With it you can add actors,
clients, change settings, and more.

### GraphQL API

The masks manager is built on top of a GraphQL API. Any actor
with the `masks:manage` scope can interact with it. This scope
should be granted judiciously.
