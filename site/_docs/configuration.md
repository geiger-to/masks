---
category: guides
title: Configuration
description: masks.json and ruby configuration
order: 1
toc: true
---

There are two ways to configure masks—a `masks.json` or an initializer that
calls `Masks.configure`. Both are generated automatically when you run
the `masks:install` generator.

## masks.json

If masks detects a file named `masks.json` in the current working directory or in `ENV['MASKS_DIR']` then it will be used as defaults.

#### example masks.json

```json
{
  "name": "my-app",
  "url": "http://localhost:3000",
  "extend": "masks",
  "masks": [
    {
      "skip": true,
      "request": {
        "method": "get",
        "path": "/assets/*"
      }
    }
  ]
}
```

## Masks.configure

While `masks.json` is suitable for most, configuration via Ruby allows more
control. All properties outlined below are supported, along with any additional
abilities outlined in the [API docs](/api).

<div role="alert" class="alert alert-info mb-4 flex items-center box-border">
  <span class="">📝</span>
  <span>
    The <code class="text-info-content">Masks.configuration</code> method can be used to inspect configuration.
  </span>
</div>

#### example Masks.configure

```ruby
Masks.configure do |config|
  config.name = "my-app"
  config.masks = [
    # supports the same data structure as masks.json
  ]
end
```

Generally speaking, configuration specified using `Masks.configure` will overwrite whatever is
in `masks.json`.

## Properties

Nearly all properties are optional, except for `masks`.

- [name](configuration.html#name)
- [title](configuration.html#title)
- [url](configuration.html#url)
- [logo](configuration.html#logo)
- [theme](configuration.html#theme)
- [extend](configuration.html#extend)
- [masks](configuration.html#masks)
- [models](configuration.html#models)
- [adapter](configuration.html#adapter)
- [lifetimes](configuration.html#lifetimes)
- [links](configuration.html#links)
- [access](configuration.html#access)

### name

`String` - a name used to identify your application. you can add a user-facing name by setting `title`. Defaults to your Rails app's name.

### title

`String` - a human-readable name for your application, used in user-facing locations like the login page and meta tags.

### url

`URI` - a canonical URI for your application, used in places where it is referenced in a generic way (e.g. a footer).

### logo

`URI` - a URI pointing to your application's logo, used in places similar to `title` (e.g. for branding on pages and favicons)

### theme

`String` - a theme name, one of the stock [daisyUI themes](https://daisyui.com/docs/themes/) or a custom theme.

### extend

`String` - the name of a gem to use as base configuration. `"masks"` is a good starting value, assuming your app is also relying on the routes and controllers provided by `Masks::Engine`.

### masks

`Mask[]` - a list of masks to use for masking [sessions](sessions.html).

When a session is created it will find an applicable mask from this list. Masks are searched from top-to-bottom and the first match wins, so list your most-specific masks first.

A `Mask` must specify properties that sessions can use for matching:

| Key     | Type       | Description                                                              |
| ------- | ---------- | ------------------------------------------------------------------------ |
| name    | `String`   | a unique name to use in cases where direct matching is preferred.        |
| request | `Request`  | for HTTP-based sessions, a hash of conditions like a method, path, etc.  |
| access  | `String[]` | for access-based sessions, a list of access names that apply to the mask |
| custom  | `Hash`     | additional data to use for matching, usually for custom sessions.        |

#### credentials and checks

Every mask must specify a set of credentials and checks unless it is set to `skip`. Access is only allowed when these conditions are met.&#x20;

| Name        | Description                                                                                                                                                                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| skip        | If true, all credentials and checks for this mask will be skipped. Masks will effectively no-op, useful for situations where you are serving public/static content.                                                                                                       |
| credentials | Credentials are classes that verify the masked session. They are specified as a string (or `Class` in Ruby) referring to the credential's class name. Masks [built-in credentials](credentials.html) are stored under `Masks::Credentials::` but you can skip the prefix. |
| checks      | All credentials perform a series of checks. Your configuration must list the checks expected to pass. You can also specify how long to accept checks that happened in the past by specifying a duration for the check.                                                    |
| actor       | Credentials must identify an actor for the session, or it is denied. The actor must match the class name supplied in this field.                                                                                                                                          |
| anon        | Some sessions are mixed-use. Set this to true (or a class name) to build and allow an anonymous actor when the credentials are unable to identify someone.                                                                                                                |
| scopes      | If using scopes, you can specify a list of scopes to require. The session actor is expected to have at least one of the scopes in this list, or access is denied.                                                                                                         |

##### example: disable masks on `/public`

```js
{
  "skip": true,
  "request": {
    "method": "GET",
    "path": "/public"
  }
}
```

#### failures

You can also specify what to do with a session after it's been masked, specifically if it doesn't pass. You can see the `fail` key to one of the following values to adjust what happens:

| Value                   | Behaviour                                                                                                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **HTTP status**         | If you specify an HTTP status code, like `401`, it will be returned along with an empty body on failure.                                                                             |
| **`controller#action`** | Pass a string in this format and the controller and action will be allowed to respond to the failed request (assuming it is a request-based session).                                |
| **`URI` or `Path`**     | Pass a valid URI or path and a `302` redirect will be returned with the URI in the `Location` header.                                                                                |
| **`false`**             | By default `fail` is a truthy value. If `false` access will be allowed even when a failure occurred. In this case, your code must be prepared to handle both pass and failed states. |

##### example: allow mixed access on `/public`

```js
{
  "type": "session",
  "request": {
    "path": "/public"
  },
  "fail": false
}
```

#### storing sessions

Sometimes you'll want to backup the results of a mask somewhere, like to the Rails session. This makes it possible for actors to rely on session cookies and duration-based access. In other cases, like with API access, it's not necessary. You can disable this functionality by adding `"backup": false` to the mask.

##### example: require a token on API requests

```js
// require a token on API requests
{
  "credentials": [
    "Key"
  ],
  "checks": {
    "actor": {}
  },
  "request": {
    "path": "/api*",
    "header": "Authorization"
  },
  "backup": "false
}
```

### types

You can create types to share common configuration across `Mask`s. This is an optional feature added to overcome JSON's limitations in this area.&#x20;

```json
{
  "types": {
    "session": {
      "credentials": ["Nickname", "Session", "Password"],
      "checks": {
        "actor": {
          "duration": "P1D"
        },
        "password": {
          "duration": "P1D"
        }
      }
    }
  },
  "masks": [
    {
      "request": {
        "path": "*",
        "type": "session"
      }
    }
  ]
}
```

### models

`Hash` - a set of models to use in adapters, credentials, and other places that interact with your data layer. See [models & adapters](/docs/models-and-adapters.html).

### adapter

`String|Class` - an adapter to use for finding and building models (primarily actors). See [models & adapters](/docs/models-and-adapters.html).

### lifetimes

`Hash` - a set of lifetimes to use in various places, specified as a number of seconds.

These values dictate how long certain information is retained by masks—inactive accounts, cookies, session data, generated tokens, etc.&#x20;

| name                 | default    |
| -------------------- | ---------- |
| `recovery_email`     | 1 hour     |
| `verification_email` | 1 hour     |
| `passwordless_email` | 10 minutes |
| `totp_drift`         | 60 seconds |
| `inactive_actor`     | 6 months   |

### links

`Hash` - a set of links to use in the frontend. Some of these will default to the routes exposed by masks' Rails engine.

### access

`Hash` - a set of default options for any access classes you build or rely on. The key should be the access name and the value a hash of data you'd like to merge on top of the access class' default options.
