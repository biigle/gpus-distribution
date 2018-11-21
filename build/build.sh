#!/bin/bash
set -e

source .env

VERSION=${1:-latest}

# This is the image which is used during build only. It stores and updates the
# Composer cache which should not be included in the production images.
# It serves as an intermediate base image for the app, worker and web images.
docker build -f build.dockerfile -t biigle/gpus-build-dist \
    --build-arg TIMEZONE=${APP_TIMEZONE} \
    --build-arg GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN} \
    --build-arg MAIA_VERSION="dev-master" \
    .

# Update the composer cache directory for much faster builds.
# Use -s to skip updating the cache directory.
ID=$(docker create biigle/gpus-build-dist)
docker cp ${ID}:/root/.composer/cache .
docker rm ${ID}

docker build -f app.dockerfile -t biigle/gpus-app-dist:$VERSION .
docker build -f worker.dockerfile -t biigle/gpus-worker-dist:$VERSION .
docker build -f web.dockerfile -t biigle/gpus-web-dist:$VERSION .
