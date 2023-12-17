---
category: guides
order: 2
toc: true
title: Sessions
description: an overview of how masks manages sessions
---

Every attempt to access something covered by masks creates a _session_—plain old
Ruby objects that coordinate, verify, and record the attempt.

## Session types

In masks, there are different types of sessions used to control access in
different contexts. The most common case is someone trying to access an HTTP endpoint
in your Rails application, but there are others—background jobs, the command
line, inline ruby code...

Masks includes built-in types for most of these situations along with the
ability to create custom types.

### HTTP requests

masks includes middleware to create a session for each HTTP request.
Controllers that include `Masks::Controller` can interact with the masked
session:

```ruby
class MyController < ApplicationController
  include Masks::Controller

  def my_action
    masked_session # => Masks::Sessions::Request
  end
end
```

For reference, the middleware ends up calling the following public method to create a request-based session:

```ruby
session = Masks.request(request) # => Masks::Session::Request
```

### Inline code

You can create a session around a block of Ruby code with the following:

```ruby
Masks.mask(name, params: {}, **data) do |session|
  # only called if session.passed? or session.mask.fail == false
end # => Masks::Session::Inline
```

This is useful in all sorts of situations, like feature flags, command-line interfaces, and testing.

### Access classes

[_Access classes_](/docs/access-classes.html) are plain old Ruby classes that are masked by a session.

Once initialized an access class creates a new session derived from a given session:

```ruby
access = masked_session.access(name) # => Masks::Accessible
access.session # => Masks::Session::Access
```

The access class will throw an error on initialization unless its session can be
masked and passes credentials and checks (just like all other sessions in
masks).

### Custom types

You can build custom session types by extending `Masks::Session`. Only three methods are required to be implemented:

- `params` - returns a hash of incoming parameters
- `data` - returns a hash of reconstituted session data (if any)
- `matches_mask?(mask)` - return `true` if the mask is applicable to the session

Once your session is implemented, create an instance and call the `mask!` method to find its mask, check credentials, and return a result.

```ruby
class ExampleSession < Masks::Session
  def params
    {}
  end

  def data
    {}
  end

  def matches_mask?(mask)
    mask.custom&.fetch(:example, false)
  end
end

session = ExampleSession.mask!(**attrs)
```

More advanced customization is outlined in the API docs.&#x20;

## Lifecycle events

After initializing a session several things occur:

1.  The session tries to find a suitable mask, or an error is raised
2.  Credentials and past checks are built according to the mask rules
3.  An actor is determined and their access is checked
4.  A pass/fail is recorded on the session

The `masks.session` event is emitted every time this happens (using the
[`ActiveSupport::Notifications`](https://guides.rubyonrails.org/active_support_instrumentation.html#subscribing-to-an-event)
framework). There are other events available:

| Event           | Description                             |
| --------------- | --------------------------------------- |
| `masks.session` | Fired for each masked session           |
| `masks.cleanup` | Fired when cleaning up a masked session |

These events are useful for instrumentation, but they don't affect the behaviour
of masks. Look into custom session types (described above) or custom credentials
if you want further control over the session lifecycle in Ruby.

## Expiration

In most applications a "session" is granted after authentication, with a lifetime
of hours or days. The session might expire if the session owner logs out, cookies
are deleted, their account is deactivated, or some other reason (like a breach).

### Lifetimes

A masked session's checks dictate its lifetime.

By default, past checks are ignored and credentials must re-run checks for
every session. If a check is configured with a `lifetime`, then past _passed_
checks are accepted, provided they occurred within the duration.

For example, consider a `masks.json` with checks like this (excerpt only):

```json
{
  "masks": [
    {
      "checks": {
        "actor": {
          "lifetime": "P1W"
        },
        "password": {
          "lifetime": "P1D"
        }
      }
    }
  ]
}
```

Any session masked by this configuration will accept prior passed `actor` and
`password` checks. Since the `password` check expires daily the overall session
lifetime is one day. Extending the `actor` check to 1 week forces the user to
supply an identifying credential (like a nickname or email) on a weekly basis.

### Logout

The Rails engine exposes a `DELETE /session` endpoint that functions as a
traditional logout endpoint. It calls `cleanup!` on the session, which gives
the mask credentials a chance to delete all related data.

The `session.cleanup` event is called on `cleanup!`.

### Versioning

Changing the base session class' `version` will expire any sessions created
using a different version:

```ruby
Masks.configuration.version = "v2" # sets the version for all session types to "v2"
```

Actors expose a similar property at the instance level. Override or recompute
their version to expire all sessions related to the actor:

```ruby
actor = Masks::Rails::Actor.find_by(...)
actor.version = SecureRandom.hex
actor.save!
```

Similarly, if checking device credentials you can expire sessions related to a
specific device:

```ruby
device = Masks::Rails::Device.find_by(actor: actor, ...)
device.version = SecureRandom.hex
device.save!
```

### Manual deletion

Request-based sessions will write data to the Rails session, if configured. Rails sessions
can be expired by changing the name of the cookie or deleting data in the storage backend.

Consult the Rails guides for information on how to do this.
