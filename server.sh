#!/usr/bin/env bash

echo -n "Checking whether Docker is installed..."

docker_installed=1
command -v docker >/dev/null 2>&1 || docker_installed=0

if (($docker_installed == 1)); then
  echo "Yes"
else
  echo "No"
  echo
  echo "To run the server, you must either install Docker or compile the individual pieces manually."
  echo "If you want to install Docker, follow instructions at the link below:"
  echo
  echo "  https://docs.docker.com/engine/installation/"
  echo
  exit 1
fi

echo -n "Checking whether Docker Compose is installed..."

docker_compose_installed=1
command -v docker >/dev/null 2>&1 || docker_compose_installed=0

if (($docker_compose_installed == 1)); then
  echo "Yes"
else
  echo "No"
  echo
  echo "To run the server, you must either install Docker Compose or run the individual pieces manually."
  echo "If you want to install Docker Compose, follow instructions at the link below:"
  echo
  echo "  https://docs.docker.com/compose/install/"
  echo
  exit 2
fi


if (($# > 0)); then
  if [ "$1" == "start" ]; then
    echo "Starting the server..."
    docker-compose up -d
  elif [ "$1" == "stop" ]; then
    echo "Stopping the server..."
    docker-compose down
  elif [ "$1" == "log" ]; then
    echo "Fetching logs..."
    docker-compose logs -f
  elif [ "$1" == "workers" ]; then
    if (($# > 1)) ; then
      echo "Setting worker count to '$2'"
      docker-compose scale worker=$2
    else
      echo "Usage: 'server.sh workers x', where 'x' is the number of worker processes"
    fi
  else
    echo "$1 is not a valid command. Try 'start', 'stop', or 'log'"
    exit 3
  fi
else
  echo "Command missing. Please try 'server.sh [command]', where command is 'start', 'stop', or 'log'"
  exit 4
fi
exit 0
