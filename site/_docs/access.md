---
category: guides
order: 3
toc: true
title: Access classes
description: controlling access to plain old Ruby classes
---

masks includes a bit of glue code to make it easier to control access to key
workflows in your application.

```ruby
class MyAccessClass
  include Masks::Access

  access "my.access"

  def foo
    "bar"
  end
end

my_access = session.access("my.access") # nil if not accessible
my_access&.foo # => 'bar' or nil
```

Read on to see how they work...

## Introduction

Access classes are plain old Ruby classes that include a bit of magic
to ensure they are only accessed by the correct sessions and actors.

To make an access class:

- Create a class and include `Masks::Access`
- Call the class' `access` method to register it with masks
- Specify mask(s) to control acccess to the class

After that, you can use the access class anywhere you have a masked session.
Any instantiation of the class will raise an error _unless_:

- it is initialized with a masked session
- the masked session's includes its name in its `access` property
- the access class is specified in your list of masks and its mask meets all requirements

### An example

Consider a Rails application that allows users to upload an avatar. This
hypothetical feature is only available to actors who have logged in and verified
their account. Once verified, they are granted the `verified` scope.

We can encapsulate the code for uploading the avatar in an access class:

```ruby
class AvatarUploader
  include Masks::Access

  access "avatar.uploader"

  def upload(file)
    avatar = Avatar.new(actor: actor, file: file)
    avatar.save
    avatar
  end
end
```

And specify the rules for accessing the class in `masks.json`, just like any other mask:

```js
{
  ...
  "masks": [
    {
      "type": "session",
      "request": {
        "path": "/avatar",
        "method": "post"
      },
      "access": ["avatar.uploader"]
    },
    {
      "access": "avatar.uploader",
      "scopes": ["verified"]
    }
  ]
}
```

Finally, in the `POST /avatar` controller (or anywhere with a masked session), the access class can be used:

```ruby
class AvatarController < ApplicationController
  include Masks::Controller

  def create
    uploader = masked_session.access("avatar.uploader")

    if uploader
      uploader.upload(params[:avatar])
    else
      flash[:error] = "verify your account to upload an avatar"
    end
  end
end
```

## Custom credentials

While access classes can be masked such that only actors with a specific scope
are able to use them, this can be limited. For more complex cases, you can
create [custom credential types](credentials.html#custom) and use them where
relevant.

For example imagine you create several access classes to implement some
functionality for an "admin-only" area. While admins are actors with the `admin`
scope, there are some additional custom checks that can only be implemented
in code.

A custom credential named `AdminRole` could take care of the logic:

```ruby
class AdminRole < Masks::Credential
  checks :admin

  def maskup
    actor.is_verified_admin? ? approve! : deny!
  end
end
```

Once implemented it can be referenced in masks configuration:

```json
{
  "types": {
    "admin-access": {
      "scopes": ["admin"],
      "checks": {
        "admin": {}
      },
      "credentials": ["AdminRole"]
    }
  },
  "masks": [
    {
      "request": {
        "path": "/admin/*"
      },
      "access": ["admin.foo", "admin.bar"]
    },
    {
      "access": "admin.foo",
      "type": "admin-access"
    },
    {
      "access": "admin.bar",
      "type": "admin-access"
    }
  ]
}
```

The `AdminFoo` and `AdminBar` access classes now require admin privileges,
as dictated by the hypothetical `#is_verified_admin?` method. If the actor
passed to the access class does not meet the requirements an exception
will be raised.

## Sessions & events

When instantiating an access class a new `Masks::Session::Access` session is
created. Parameters and data are inherited from the original session passed to
the access class.

As outlined in the docs on [sessions](sessions.html), the `masks.session` event
will report any instantiated access classes making it easy to instrument and
monitor key workflows in your application.

## Further reading

Access classes can be used in all sorts of situations—if it can be masked, you
can create and control the access classes that are available to the session.

Refer to the [API docs](/api) for more information.
