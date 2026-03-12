#!/bin/sh

rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/bootsnap

pnpm install --frozen-lockfile

echo "Ready to run Vite development server."

exec "$@"
