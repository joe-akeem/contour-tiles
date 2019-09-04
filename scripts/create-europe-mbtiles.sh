#!/usr/bin/env bash

mkdir -p target/streets
cd target/streets

# ---------------------------------------------------------------------------------------------------------------------
# TODO: get OSM data and load it into the database
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# Generate general mbtiles file (from PostGIS database)
# ---------------------------------------------------------------------------------------------------------------------

# landuse
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 landuse.geojson "PG:host=localhost dbname=gis user=osm" -sql @landuse.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' landuse.geojson

# admin
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 admin.geojson "PG:host=localhost dbname=gis user=osm" -sql @admin.sql

# buildings
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 building.geojson "PG:host=localhost dbname=gis user=osm" -sql @building.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' building.geojson

# landuse overlay
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 landuse_overlay.geojson "PG:host=localhost dbname=gis user=osm" -sql @landuse_overlay.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' landuse_overlay.geojson

# major roads
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 road.geojson "PG:host=localhost dbname=gis user=osm" -sql @major_road.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' road.geojson

# minor roads
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 minor_road.geojson "PG:host=localhost dbname=gis user=osm" -sql @minor_road.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' minor_road.geojson

# merge minor_road.geojson into road.geojson and delete minor_road.geojson
ogr2ogr -f GeoJSON -append road.geojson minor_road.geojson
rm minor_road.geojson

# rivers - shown from at zoom level 7 and up
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

# big waters - show from zoom level 0
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 water.geojson "PG:host=localhost dbname=gis user=osm" -sql @water_big.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' water.geojson

# medium waters - show from zoom level 7
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 water_medium.geojson "PG:host=localhost dbname=gis user=osm" -sql @water_medium.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' water_medium.geojson

# small waters - show from zoom level 13
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 water_small.geojson "PG:host=localhost dbname=gis user=osm" -sql @water_small.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' water_small.geojson

ogr2ogr -f GeoJSON -append water.geojson water_medium.geojson
ogr2ogr -f GeoJSON -append water.geojson water_small.geojson
rm water_medium.geojson
rm water_small.geojson

# ---------------------------------------------------------------------------------------------------------------------
# Merge everything into one big mbtiles file. The geojson files become the layers
# ---------------------------------------------------------------------------------------------------------------------
#tippecanoe -f -o europe.mbtiles -zg --drop-densest-as-needed *.geojson
tippecanoe -f -o europe.mbtiles *.geojson


# ---------------------------------------------------------------------------------------------------------------------
# Upload mbtiles and tileserver config to singletrail-map.eu
# ---------------------------------------------------------------------------------------------------------------------
scp -i ~/.ssh/aws.pem europe.mbtiles ec2-user@singletrail-map.eu:/home/ec2-user
scp -i ~/.ssh/aws.pem config/tileserver-config.json ec2-user@singletrail-map.eu:/home/ec2-user
