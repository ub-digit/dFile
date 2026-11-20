#!/usr/bin/env bash

# Find GIT_REVISION from .env file
GIT_REVISION=$(grep GIT_REVISION .env | cut -d '=' -f2)

IMAGE="docker.ub.gu.se/dfile:${GIT_REVISION}"

FILEVAULT=/data/filevault
INSIDE_FILEVAULT=/usr/src/app/filevault

docker run --rm -it --name test-dfile \
  -v ${FILEVAULT}:${INSIDE_FILEVAULT} \
  -e RAILS_ENV=production \
  -e ENVIRONMENT=production \
  -e SECRET_KEY_BASE=testtesttest \
  -p 127.0.0.1:8888:3000 \
  ${IMAGE}
