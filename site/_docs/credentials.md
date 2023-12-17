---
category: guides
title: Credentials
description: a guide to how "credentials" work in masks
order: 4
toc: true
---

Credentials work together to do three things:

- identify an _actor_ for the session
- if identified, verify the actor's access
- if verified, record results for future checks

Every masked session can be configured to run through a number of credentials,
executed in the order they're specified in your configuration. In some
cases, credentials can be composed to enable or disable different features.

## Credential types

Masks built-in credentials are designed to work together to support the
common access control workflows, but custom credentials are easy to implement.

### Built-in

Here are some of the commonly used built-in types:

- `Session` checks `actor` using the rails session
- `Nickname` checks `actor` using a nickname supplied via params
- `EmailAddress` checks `actor` using an email address supplied via params
- `PhoneNumber` checks `actor` using a phone number supplied via params
- `BearerToken` checks `actor` using a bearer token sent via the Authorization header
- `Password` checks `password` using a password supplied via params
- `Device` checks `device` using various signals from the session
- `OneTimePassword` checks `factor2` using a params-supplied code
- `BackupCode` checks `factor2` using a params-supplied code

All of the built-in types are namespaced under `Masks::Credentials`. Check out
the [API docs](/api/Masks/Credentials.html) for information on each of them.

### Custom

Credentials are simple Ruby classes that extend `Masks::Credential`, so custom
credentials are easy to make. For example:

```ruby
class MyCustomCredential < Masks::Credential
  checks :custom

  def lookup
    # hook called when searching for an actor. This method
    # should return an actor if it thinks it can find something
    # based on the session context. (optional)
    configuration.model(:actor).first if params[:custom]
  end

  def maskup
    # hook called when an actor is available. should call
    # approve! or deny! (or nothing) to verify the actor
    # provided it exists. This affects only the "custom" check.
    actor ? approve! : deny!
  end

  def backup
    # final lifecycle hook, called once a decision has been
    # made about the overall session (optional).
  end
end
```

Once implemented, reference it in the appropriate mask(s) just like any other credential:

```json
{
  ...
  "credentials": [
    "MyCustomCredential"
  ],
  "checks": {
    "custom": {
      "lifetime": "P1D"
    }
  }
}
```

## More examples

Take a look at the following examples illustrating how credentials are
referenced in `masks.json`:

### Login endpoint

The mask for a hypothetical endpoint that exchanges a nickname/password
for a session token would look similar to the following:

```json
{
  "request": {
    "path": "/session",
    "method": "POST"
  },
  "credentials": ["Session", "Email", "Nickname", "Password", "LastLogin"],
  "checks": {
    "actor": {
      "lifetime": "P1D"
    },
    "password": {
      "lifetime": "P1D"
    }
  }
}
```

The `Session`, `Email`, and `Nickname` credentials work together to check the
`actor`, while `password` is checked by the `Password` credential. If two-factor
authentication support is added then the various credentials for managing that
process would need to be added.

### Masquerading

A simple mask to allow acting as an account without any real checks (useful, for example, during system tasks) would look like this:

```json
{
  "name": "my-task",
  "credentials": ["Masquerade"],
  "checks": {
    "actor": {}
  }
}
```

Then in Ruby, perhaps a command-line script:

```ruby
Actor.find_each do |actor|
  Masks.mask("my-task", as: actor) { |session| perform_system_task session }
end
```

### Access classes

Take a look at the page on [access classes](access.html#custom-credentials) for
examples on integrating them with [custom credentials](#custom).

### Source code

masks itself ships a `masks.json` that is easy to read and extend. Take a look
at the source code to see how actual masks and credentials for login, signup,
password recovery, and more are set up.
