#!/usr/bin/env bash

TRY_LOOP="20"

: "${EXECUTOR:="CeleryExecutor"}"

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

if [ "$EXECUTOR" = "CeleryExecutor" ]; then
  wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
fi


wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"


case "$1" in
  webserver)
    airflow initdb
	sleep 5

	if [ "$EXECUTOR" = "LocalExecutor" ]; then
      # With the "Local" executor it should all run in one container.
      airflow scheduler &
    fi

    # TODO here we can add a custom script for example to load

    if [ "$AIRFLOW__WEBSERVER__AUTHENTICATE" = "True" ]; then
      # With the "Local" executor it should all run in one container.
      python /usr/local/airflow/add_admin_user.py
    fi

    exec airflow webserver
    ;;
  worker|scheduler)
    sleep 15
    exec airflow "$@"
    ;;
  flower)
    sleep 15
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
