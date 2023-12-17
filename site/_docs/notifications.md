---
category: guides
title: Notifications
description: todo
order: 5
toc: true
---

Masks sends a number of notifications, some time-sensitive, over various
configurable communication channels, like Email, SMS, and Push.

## Configuration

Each of the following notification types can be toggled and configured:

- actor_created
- actor_stale
- actor_expiring
- actor_expired
- device_added
- recovery_requested
- approval_requested
- otp_requested
- version_changed
- password_changed
- factor2_changed
- email_changed
- temporary_password
- custom_message

### Delivery mediums

Notifications can be sent over a few mediums:

- **email** - sent if the actor has an email and the actor's `#notify_email?(type)` returns a truthy value
- **phone** - sent if the actor has a phone number and the actor's `#notify_sms?(type)` returns a truthy value
- **push** - sent if the actor has a device and its `#notify_push?(type)` returns a truthy value

### Notification types

For example, a number of notifications can be sent when someone hasn't logged
into their account for increasing periods of time, ultimately leading to
permanent deletion. These can disabled entirely just like other
[configuration](configuration.html):

```ruby
{
  notifications: {
    actor_stale: false,
    actor_expiring: false,
    actor_expired: false
  }
}
```

Notifications are delivered using [noticed](https://github.com/excid3/noticed)

Emails are delivered using [Action Mailer](https://guides.rubyonrails.org/action_mailer_basics.html),
so they will be sent according to its configuration.
