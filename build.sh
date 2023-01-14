#!/usr/bin/env bash
# Purpose: Build and a static site
# Usage: build.sh [--clean|--purge]
# Examples:
# $ source ./build-setenv-stage.sh ;
# $ ./build.sh
# $ ./build.sh --clean
# $ ./build.sh --purge
clean="${1:-false}" ;
purge="${1:-false}" ;
noMirror="${1:-false}" ;

# Clean-up of java components (not needed if running on a fresh container)
if [[ "$clean" = "--clean" || "$purge" = "--purge" ]]; then
  rm -rf './target' ;
fi

# Clean-up of docker elements (not needed if running on a fresh container)
docker compose --file ./docker-compose-mount-content.yml down --remove-orphans ;
docker compose down --remove-orphans ;
if [ "$purge" = "--purge" ]; then
  docker system prune --all --volumes --force ;
fi

# Build docker images to create a local cluster
mkdir -p './mirror'
docker compose --file ./docker-compose-mount-content.yml build --no-cache --pull ;
docker compose --file ./docker-compose-mount-content.yml up --force-recreate --detach ;
until docker compose --file ./docker-compose-mount-content.yml ps | grep -v -e 'NAME' | wc -l | grep -e '^[[:space:]]*0[[:space:]]*$' ; do echo "Waiting for content..." ; sleep 1 ; done ;
docker compose build --no-cache --pull ;
docker compose up --force-recreate --detach ;
until docker compose logs --tail="all" | grep -e 'Tomcat started on port(s): 8080 (http)' ; do echo "Waiting for the app..." ; sleep 1 ; done ;
docker compose logs --tail="all" ;

if [[ "$noMirror" != "--noMirror" ]]; then
  ./create-mirror-from-cluster.sh ;
fi
