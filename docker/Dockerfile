# syntax=docker/dockerfile:1.4
# pre-build stage
FROM node:24-alpine AS node
FROM ruby:3.4.4-alpine3.21@sha256:5bdfa2312f3f0bc9bd077e954c943652155a093db228af978873ff92389300d3 AS pre-builder
ARG PNPM_VERSION="10.2.0"
ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}

ENV BUNDLER_VERSION=4.0.2

ENV BUNDLE_PATH="/gems"

RUN apk add --no-cache \
  openssl \
  tar \
  build-base \
  tzdata \
  postgresql-dev \
  postgresql-client \
  git \
  curl \
  xz \
  musl \
  gcc \
  make \
  musl-dev \
  openssl-dev \
  g++ \
  linux-headers \
  vips \
  yaml-dev \
  && mkdir -p /var/app \
  && gem install bundler -v ${BUNDLER_VERSION}

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN npm install -g pnpm@${PNPM_VERSION}

# ARG default to production settings
# For development docker-compose file overrides ARGS
ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ARG NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"
ENV NODE_OPTIONS=${NODE_OPTIONS}

RUN echo 'export PNPM_HOME="/root/.local/share/pnpm"' >> /root/.shrc \
  && echo 'export PATH="$PNPM_HOME:$PATH"' >> /root/.shrc \
  && export PNPM_HOME="/root/.local/share/pnpm" \
  && export PATH="$PNPM_HOME:$PATH" \
  && pnpm --version

# Persist the environment variables in Docker
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# Use system libraries for nokogiri (avoids linking issues)
RUN apk add --no-cache libxml2-dev libxslt-dev zlib-dev
RUN bundle config build.nokogiri --use-system-libraries

# natively compile grpc and protobuf to support alpine musl (dialogflow-docker workflow)
# https://github.com/googleapis/google-cloud-ruby/issues/13306
RUN bundle config set --local force_ruby_platform true

# Do not install development or test gems in production
# Using BuildKit cache mount for faster rebuilds
RUN --mount=type=cache,target=/gems/ruby/3.4.0/cache \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle config set without 'development test'; bundle install -j 4 -r 3; \
  else bundle install -j 4 -r 3; \
  fi

COPY package.json pnpm-lock.yaml ./
# Using BuildKit cache mount for pnpm store
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
  pnpm install --frozen-lockfile

COPY . /app

# creating a log directory so that image wont fail when RAILS_LOG_TO_STDOUT is false
RUN mkdir -p /app/log

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
  SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled bundle exec rake assets:precompile \
  && rm -rf spec node_modules tmp/cache; \
  fi

ARG GIT_SHA="unknown"

# Generate .git_sha file with current commit hash (passed via build-arg)
RUN echo "${GIT_SHA}" > /app/.git_sha

# Remove unnecessary files
RUN rm -rf /gems/ruby/3.4.0/cache/*.gem \
  && find /gems/ruby/3.4.0/gems/ \( -name "*.c" -o -name "*.o" \) -delete \
  && rm -rf .git .gitignore 2>/dev/null || true

# final build stage — runtime only (no build tools)
FROM ruby:3.4.4-alpine3.21@sha256:5bdfa2312f3f0bc9bd077e954c943652155a093db228af978873ff92389300d3 AS final

ARG PNPM_VERSION="10.2.0"
ENV PNPM_VERSION=${PNPM_VERSION}

ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=4.0.2

ARG EXECJS_RUNTIME="Disabled"
ENV EXECJS_RUNTIME=${EXECJS_RUNTIME}

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}

ARG BUNDLE_FORCE_RUBY_PLATFORM=1
ENV BUNDLE_FORCE_RUBY_PLATFORM=${BUNDLE_FORCE_RUBY_PLATFORM}

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH="/gems"

# Runtime-only dependencies (no build-base, gcc, g++, git)
RUN apk add --no-cache \
  openssl \
  tzdata \
  postgresql-client \
  imagemagick \
  curl \
  vips \
  libxml2 \
  libxslt \
  && gem install bundler -v ${BUNDLER_VERSION}

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN if [ "$RAILS_ENV" != "production" ]; then \
  ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g pnpm@${PNPM_VERSION} \
  && pnpm --version; \
  fi

COPY --from=pre-builder /gems/ /gems/
COPY --from=pre-builder /app /app

WORKDIR /app

# Create non-root user for running the application
RUN addgroup -S rails && adduser -S rails -G rails \
  && chown -R rails:rails /app /gems

USER rails

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
