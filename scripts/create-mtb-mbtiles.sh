#!/usr/bin/env bash

mkdir -p target/mtb

# ---------------------------------------------------------------------------------------------------------------------
# TODO: get OSM data and load it into the database
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# Generate MTB mbtiles file (from PostGIS database)
# ---------------------------------------------------------------------------------------------------------------------

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 mtb_scale.geojson "PG:host=localhost dbname=gis user=osm" -sql @mtb.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 8 },/g' mtb_scale.geojson


# ---------------------------------------------------------------------------------------------------------------------
# Merge everything into mbtiles file.
# ---------------------------------------------------------------------------------------------------------------------
tippecanoe -f -o mtb.mbtiles *.geojson


# ---------------------------------------------------------------------------------------------------------------------
# Upload mbtiles config to singletrail-map.eu
# ---------------------------------------------------------------------------------------------------------------------
scp -i ~/.ssh/aws.pem mtb.mbtiles ec2-user@singletrail-map.eu:/home/ec2-user
scp -i ~/.ssh/aws.pem config/tileserver-config.json ec2-user@singletrail-map.eu:/home/ec2-user
