---
category: guides
title: Getting started
description: how to install and use masks
toc: true
---

masks is a general purpose access control framework for ruby/rails.

While masks is highly configurable, it ships with "batteries-included" tooling
for common access control workflows across a variety of contexts.

## Quickstart

To use it, add `masks` to your Gemfile or run:

```sh
bundle add masks
```

Then run the installation:

```sh
rails generate masks:install
```

A typical installation creates a `masks.json`, an initializer, migrations, and routes.

## Getting started

If you're just getting started, take a look at the various guides for information on how to use masks:

- [Configuring masks](/docs/configuration.html) with `masks.json` or Ruby
- Learn [how sessions work](/docs/sessions.html) in masks
- Make and consume [access classes](/docs/access.html) in your app

If you're familiar with masks, the API docs may be more useful:

- [Ruby API](/api)
