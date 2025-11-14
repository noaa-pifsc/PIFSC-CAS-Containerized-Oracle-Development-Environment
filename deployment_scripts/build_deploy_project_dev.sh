#! /bin/sh

# change to the directory the script is running in
cd "$(dirname "$(realpath "$0")")"/../docker

# build and execute the docker container for the development scenario
docker-compose -f docker-compose-dev.yml up -d  --build

# notify the user that the container has finished executing
echo "The dev docker container has finished building and is running"
