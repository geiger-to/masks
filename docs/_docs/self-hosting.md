---
category: guides
title: Self-hosting
description: how to self-host a masks installation
toc: true
order: -1
---

You can run masks using any container orchestration tool, including Docker,
Portainer, and Kubernetes. Refer to the [configuration
guides](configuration.html) for information on available environment variables
and `masks.yml` options.

## Official images

**Latest tag**: `{% version %}`

- Docker: [masksrb/masks](#)
- Github: [masksrb/masks](#)

## Dependencies

Masks depends on the following:

- A database, SQLite or PostgreSQL
- Network access, for communication with various APIs
- SSL/TLS certificates

{% capture ssl_note %}
<span>
<b>Note:</b> SSL/TLS is <i>required</i>. You must configure masks with SSL
certificates or use a proxy like Caddy, traefik, or nginx with LetsEncrypt.
</span>
{% endcapture %}

{% include alert.html class="text-warning" content=ssl_note %}

## Examples

### docker-compose.yml

The following example runs Caddy, PostgreSQL, and the masks web server + job workers.

```yaml
services:
  caddy:
    image: caddy:2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./data/caddy-data:/data
      - ./data/caddy-config:/config
    depends_on:
      - masks

  masks:
    image: masksrb/masks:latest
    ports:
      - "5000:5000"
    environment:
      MASKS_URL: https://masks.localhost
      MASKS_MANAGER_PASSWORD: password
      MASKS_DB_URL: postgres://masks:masks@db:5432/masks
    volumes:
      - ./data/masks:/masks/data
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: masks
      POSTGRES_PASSWORD: masks
      POSTGRES_DB: masks
      PGUSER: masks
    ports:
      - "5432:5432"
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready", "-d", "masks"]
      interval: 30s
      timeout: 60s
      retries: 5
      start_period: 80s
```

## Tips & FAQ

### Migrations

Database migrations are run before the server boots, automatically. To disable
this behaviour, set `SKIP_MIGRATIONS=true` and run migrations manually with
the following command:

```
$ masks migrate
```

You could, for example, run the tasks manually on the command line (assuming you're hosting with docker):

```sh
$ docker run masks masks migrate
```

Another option is to run it as a task before deploying the masks server. For example, in `docker-compose.yml`:

```yaml
services:
  migrate:
    image: masksrb/masks:latest
    command: ["masks", "migrate"]
    restart: "no"
    # etc...

  masks:
    image: masksrb/masks:latest
    depends_on:
      migrate:
        condition: service_completed_succesfully
    # etc...
```

### Scaling

Masks is write-heavy, meaning database performance will heavily impact the
overall application performance.

The official image boots a multi-threaded HTTP(s) server and workers for
handling background jobs. By default, one masks container runs 2 processes (web
and job), each with multiple independent threads (5, if not specified).

This works fine for low-traffic setups, but higher-traffic setups benefit from
the following changes:

- Increase the number of replicas with your container orchestration tool
- Override the boot command to start more processes:
  - `masks start web=2,job=2` will start 2 web and processes
- Increase the number of threads per-process with `MASKS_THREADS=n`
- Deploy the containers handling web requests and jobs independently
  - `masks start job=1` will start one job process
  - `masks start web=1` will start one web process

For example, in a `docker-compose.yml`:

```yaml
services:
  masks-job:
    image: masksrb/masks:latest
    command: ["masks", "start", "job=5"]
    # etc...

  masks-web:
    image: masksrb/masks:latest
    command: ["masks", "start", "web=5"]
    # etc...
```
