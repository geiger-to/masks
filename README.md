# masks

masks is a general purpose access control framework for ruby/rails.

## Getting started

To use it, add `masks` to your Gemfile or run:

```
bundle add masks
```

Then run the install generator:

```
rails generate masks:install
```

A typical install creates a `masks.json`, an initializer, and migrations. After
running the generator your app will be able to use masks' signup, login, and account
management features. Every route in your app will be protected by login by default.

## Documentation

Full documentation is available at [masks.geiger.to](https://masks.geiger.to).

## How it works

At the heart of masks are a few key concepts:

- **Masks** are rules that define access to resources in your application
- **Actors** access resources via sessions (if allowed by the mask)
- **Sessions** keep track of attempts to access resources
- **Credentials** identify and check actors' access using session data

masks implements most of the glue code required to build actors, open sessions,
and check credentials, leaving your application to defining the _masks_ required
for it to function. typically all you need is a `masks.json` file, but you can
also build custom credentials, checks, models, and more...

#### an example `masks.json`

```json
{
  "name": "example",
  "url": "http://example.com",
  "logo": "...",
  "extend": "masks"
}
```
