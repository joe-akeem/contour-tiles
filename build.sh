#!/usr/bin/env bash

TILESERVER_VERSION="latest"

cd tiles-builder
docker build -t joeakeem/tiles-builder:$TILESERVER_VERSION .

cd ../tiles-server/
docker build -t joeakeem/tiles-server:$TILESERVER_VERSION .

cd ../tiles-proxy/
docker build -t joeakeem/tiles-proxy:$TILESERVER_VERSION .

cd ../tiles-docs/
docker build -t joeakeem/tiles-doc:$TILESERVER_VERSION .

docker push joeakeem/tiles-builder:$TILESERVER_VERSION
docker push joeakeem/tiles-server:$TILESERVER_VERSION
docker push joeakeem/tiles-doc:$TILESERVER_VERSION
docker push joeakeem/tiles-proxy:$TILESERVER_VERSION