#!/usr/bin/env bash

mkdir -p target/contour

# ---------------------------------------------------------------------------------------------------------------------
# Get terrain data, see http://srtm.csi.cgiar.org/srtmdata/
# ---------------------------------------------------------------------------------------------------------------------
wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_38_03.zip -O target/contour/srtm_38_03.zip #Alps West
wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_39_03.zip -O target/contour/srtm_39_03.zip #Alps East
cd target/contour
unzip -p srtm_38_03.zip srtm_38_03.tif > srtm_38_03.tif
unzip -p srtm_39_03.zip srtm_39_03.tif > srtm_39_03.tif

# Merge the terrain data files into one file
gdal_merge.py -o alps-4326.tif srtm_38_03.tif srtm_39_03.tif

#  Re-project
gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear alps-4326.tif alps-3785.tif

# ---------------------------------------------------------------------------------------------------------------------
# Generate hill shading
# ---------------------------------------------------------------------------------------------------------------------
gdaldem hillshade -z 5 alps-3785.tif alps-3785-hillshade.tif
gdal_translate alps-3785-hillshade.tif alps-hillshade.mbtiles -of MBTILES
gdaladdo -r nearest hillshade.mbtiles 2 4 8 16

# ---------------------------------------------------------------------------------------------------------------------
# Generate slope shading
# ---------------------------------------------------------------------------------------------------------------------
gdaldem slope alps-3785.tif alps-3785-slope.tif
gdal_translate alps-3785-slope.tif alps-slope.mbtiles -of MBTILES
gdaladdo -r nearest slope.mbtiles 2 4 8 16

# ---------------------------------------------------------------------------------------------------------------------
# Load contour lines to PostGIS
# ---------------------------------------------------------------------------------------------------------------------
gdal_contour -a elev -i 20 alps-4326.tif alps-4326-contour20.tif
gdal_contour -a elev -i 100 alps-4326.tif alps-4326-contour100.tif
gdal_contour -a elev -i 20 alps-3785.tif alps-3785-contour20.tif

# load countour lines INto PostGIS so we can query them in different ways
shp2pgsql -s 3857 alps-3785-contour20.tif/contour.shp contourlines | psql -h localhost -d gis -U osm


# ---------------------------------------------------------------------------------------------------------------------
# Generate contour mbtiles file (from PostGIS database)
# ---------------------------------------------------------------------------------------------------------------------

# normal contour lines for 20 and 100 meters
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 contour.geojson "PG:host=localhost dbname=gis user=osm" -sql @contour20.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' contour.geojson

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @contour100.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' contour100.geojson

# glacier contour lines for 20 and 100 meters
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 glacier_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @glacier_contour20.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' glacier_contour20.geojson

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 glacier_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @glacier_contour100.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' glacier_contour100.geojson

# rock contour lines for 20 and 100 meters
ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 rock_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @rock_contour20.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' rock_contour20.geojson

ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 rock_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @rock_contour100.sql
sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' rock_contour100.geojson

# merge contour lines into one file
ogr2ogr -f GeoJSON -append contour.geojson contour100.geojson
ogr2ogr -f GeoJSON -append contour.geojson glacier_contour20.geojson
ogr2ogr -f GeoJSON -append contour.geojson glacier_contour100.geojson
ogr2ogr -f GeoJSON -append contour.geojson rock_contour20.geojson
ogr2ogr -f GeoJSON -append contour.geojson rock_contour100.geojson


# ---------------------------------------------------------------------------------------------------------------------
# Merge everything into one big mbtiles file. The geojson files become the layers
# ---------------------------------------------------------------------------------------------------------------------
tippecanoe -f -o contour.mbtiles contour.geojson


# ---------------------------------------------------------------------------------------------------------------------
# Upload mbtiles and tileserver config to singletrail-map.eu
# ---------------------------------------------------------------------------------------------------------------------
scp -i ~/.ssh/aws.pem contour.mbtiles ec2-user@singletrail-map.eu:/home/ec2-user
scp -i ~/.ssh/aws.pem config/tileserver-config.json ec2-user@singletrail-map.eu:/home/ec2-user
