---
category: guides
title: Clients
description: how clients work in masks
toc: true
order: 0
---

In simple terms, _clients_ are systems that use masks for authentication and
access control.

In technical terms, clients represent your computing resources. Any protected
resource that speaks OAuth/OpenID Connect can delegate authentication to a
masks installation, provided there is a corresponding client for the system.

Clients have their own set of secrets, settings, and behaviour.
You can customize the look and feel of each client, the checks necessary for
access, and other aspects of how they work.

## Types of clients

There are different client types in masks, depending on your needs.

### Internal

Internal clients do not create authorization codes, access tokens, or other
OAuth artifacts. In fact, they don't work with the traditional OAuth protocol
at all. Instead, masks sets cookies after authentication—allowing any application
hosted on the same cookie domain as the masks installation to see the current
authentication status.

<span id="management-client" />

#### The management client

Every masks installation comes pre-built with a management client—an _internal_
client that restricts access to `/manage` and the Management API. It only
allows actors with the `masks:manage` scope to manage the installation.

### Confidential

Confidential clients are for web services with a backend capable of keeping
secrets from the outside world. They can use the authorization endpoint to
receive authorization codes and create access tokens.

### Public

Public clients receive access tokens directly, since they are unable to keep
the secret needed to exchange an authorization code for an access code safe.

<span id="defaults" />

## Default settings

You can customize the default settings for clients by setting any of the
following in your `masks.yml`:

| name                                         | default             |
| -------------------------------------------- | ------------------- |
| clients.checks                               | device, credentials |
| clients.scopes.required                      |                     |
| clients.scopes.allowed                       |                     |
| clients.client_type                          | internal            |
| clients.subject_type                         | pairwise-uuid       |
| clients.sector_identifier                    |                     |
| clients.allow_passwords                      | true                |
| clients.allow_login_links                    | true                |
| clients.autofill_redirect_uri                | false               |
| clients.fuzzy_redirect_uri                   | false               |
| clients.bg_light                             |                     |
| clients.bg_dark                              |                     |
| clients.id_token_expires_in                  | `6 hours`           |
| clients.access_token_expires_in              | `6 hours`           |
| clients.authorization_code_expires_in        | `10 minutes`        |
| clients.internal_token_expires_in            | `1 day`             |
| clients.login_link_expires_in                | `10 minutes`        |
| clients.auth_attempt_expires_in              | `1 hour`            |
| clients.login_link_factor_expires_in         | `12 hours`          |
| clients.sso_factor_expires_in                | `3 hours`           |
| clients.refresh_token_expires_in             | `1 month`           |
| clients.password_factor_expires_in           | `1 day`             |
| clients.second_factor_backup_code_expires_in | `1 hour`            |
| clients.second_factor_phone_expires_in       | `10 minutes`        |
| clients.second_factor_totp_code_expires_in   | `10 minutes`        |
| clients.second_factor_webauthn_expires_in    | `10 minutes`        |
| clients.email_verification_expires_in        | `1 year`            |
