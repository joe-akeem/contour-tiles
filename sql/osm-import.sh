co#!/bin/bash

DB_HOST=localhost
DB_PORT=5432
DB_USER=osm
DB_DATABASE=gis


rm -rf target/osm-import
mkdir -p target/osm-import

echo "Downloading OSM data..."
curl http://download.geofabrik.de/europe/switzerland-latest.osm.pbf --output target/osm-import/switzerland.osm.pbf
curl https://download.geofabrik.de/europe/germany/bayern/oberbayern-latest.osm.pbf --output target/osm-import/oberbayern.osm.pbf

echo "importing OSM data to PostGIS..."
osm2pgsql --create --slim --host $DB_HOST --port $DB_PORT --username $DB_USER --database $DB_DATABASE --hstore-column mtb target/osm-import/switzerland.osm.pbf
osm2pgsql --append --slim --host $DB_HOST --port $DB_PORT --username $DB_USER --database $DB_DATABASE --hstore-column mtb target/osm-import/oberbayern.osm.pbf
