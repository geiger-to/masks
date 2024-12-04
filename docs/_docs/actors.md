---
category: guides
title: Actors
description: users are actors in masks
toc: true
order: 0
---

Masks authenticates _actors_—people (and computers) who want access to [a
client's](clients.html) resources.

## Defaults

### Credentials

Actors authenticate with _credentials_, some of which may be usable on the
client they're accessing (depending on its settings).

- Device
- Nickname
- Email
- Password
- Passkey
- Login link
- SMS code
- TOTP
- Webauthn
- Backup codes

### Scopes

Actors are granted access with _scopes_. For example, only actors with the
`masks:manage` scope can manage the masks installation. Other scopes are
required to add and invite actors, or create clients, and so on.

The following scopes are used internally for actors with the ability to manage
all or part of masks:

| masks:clients | r/w access to clients |
| masks:actors | r/w access to actors |
| masks:install | r/w access to settings |
| masks:manage | super-user access, includes all `masks:` scopes. |

Since there are no other scopes built-in to the system, you are free to create
and use any number to fit your needs. Scopes must be url-encodable and without
whitespace.

## Invitation & signup

You can add actors to your installation in a number of ways:

- managers can use `/manage` or the Management API
- confidential clients using the Actor API
- web-based signup and invitation flows, when enabled
- with seed data

## Password hashing
