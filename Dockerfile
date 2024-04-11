# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.1.4
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler


# Throw-away build stages to reduce size of final image
FROM base as prebuild

# Install packages needed to build gems and node modules
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl libpq-dev node-gyp pkg-config python-is-python3


FROM prebuild as node

# Install Node.js
ARG NODE_VERSION=21.6.1
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/node-build-master

# Install node modules
COPY --link package.json ./
RUN --mount=type=cache,id=bld-npm-cache,target=/root/.npm \
    npm install


FROM prebuild as build

# Copy application code
COPY --link . .

# Install application gems
RUN --mount=type=cache,id=bld-gem-cache,sharing=locked,target=/srv/vendor \
    bundle config set app_config .bundle && \
    bundle config set path /srv/vendor && \
    bundle install && \
    bundle clean && \
    mkdir -p vendor && \
    bundle config set path vendor && \
    cp -ar /srv/vendor .

# Copy node modules
COPY --from=node /rails/node_modules /rails/node_modules
COPY --from=node /usr/local/node /usr/local/node
ENV PATH=/usr/local/node/bin:$PATH

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN npm run build
RUN npm run build:css
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails app:assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 postgresql-client

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
RUN mkdir /data && touch /data/masks.sqlite3 && chown -R 1000:1000 /data
RUN chown -v -R 1000:1000 /rails/dummy/tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Set a default database (using sqlite3)
ENV DATABASE_URL="sqlite3:///data/masks.sqlite3"
ENV FORCE_SSL=false

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
