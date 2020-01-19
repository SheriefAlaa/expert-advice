#!/bin/bash -x
# Docker entrypoint script.
# -x echos commands

# Setup a cron schedule to renew the certificates
# Try every night after midnight
# echo "33 0 * * * certbot renew >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt

# crontab scheduler.txt
# cron

# Wait until Postgres is ready
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

exec mix do ecto.create, ecto.migrate, phx.server