---
category: guides
title: Background jobs
description: optional async work employed by masks
order: 6
toc: true
---

Masks ships a number of background jobs to facilitate common asynchronous workflows.
All of these jobs are optional, but you should considering scheduling them or replicating
their functionality to ensure your app's masks installation works optimally.

## Cron jobs

Some of the jobs masks includes are intended to be scheduled on a semi-regularly
cadence, depending on the lifetimes set in [masks configuration](configuration.html#lifetimes).

### `ExpireActorsJob`

Deletes actors that have not logged in after a period of time.

[API docs](/api/Masks/ExpireActorsJob)
