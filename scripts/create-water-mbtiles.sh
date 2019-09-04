#!/usr/bin/env bash

mkdir -p target/water
cd target/water

# ---------------------------------------------------------------------------------------------------------------------
# Generate waterway geojson file (from PostGIS database)
# ---------------------------------------------------------------------------------------------------------------------

# Rivers - shown from at zoom level and up
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 waterway.geojson "PG:host=localhost dbname=gis user=osm" -sql @waterway_river.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' waterway.geojson

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 waterway_canal_stream.geojson "PG:host=localhost dbname=gis user=osm" -sql @waterway_canal_stream.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' waterway_canal_stream.geojson

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 waterway_ditch_drain.geojson "PG:host=localhost dbname=gis user=osm" -sql @waterway_ditch_drain.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 15 },/g' waterway_ditch_drain.geojson

# merge all waterway layers into one
ogr2ogr -f GeoJSON -append waterway.geojson waterway_canal_stream.geojson
ogr2ogr -f GeoJSON -append waterway.geojson waterway_ditch_drain.geojson
rm waterway_canal_stream.geojson
rm waterway_ditch_drain.geojson

