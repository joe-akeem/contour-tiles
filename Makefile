DB_HOST := localhost
DB_PORT := 5432
DB_USER := osm
DB_DATABASE := gis

# ----------------------------------------------------------------------------------------------------------------------
#	Main Targets
# ----------------------------------------------------------------------------------------------------------------------

all: shp2pgsql-osm shp2pgsql-contour contour mtb europe

europe: data/mbtiles/europe.mbtiles

mtb: data/mbtiles/mtb.mbtiles

contour: data/mbtiles/hillshade.mbtiles data/mbtiles/slope.mbtiles data/mbtiles/contour.mbtiles

shp2pgsql-osm: data/download/switzerland.osm.pbf data/download/oberbayern.osm.pbf
	osm2pgsql --create --slim --host $(DB_HOST) --port $(DB_PORT) --username $(DB_USER) --database $(DB_DATABASE) --hstore-column mtb data/download/switzerland.osm.pbf
	osm2pgsql --append --slim --host $(DB_HOST) --port $(DB_PORT) --username $(DB_USER) --database $(DB_DATABASE) --hstore-column mtb data/download/oberbayern.osm.pbf

shp2pgsql-contour: data/tif/contour-3785-20m.tif
	shp2pgsql -s 3857 data/tif/contour-3785-20m.tif/contour.shp contourlines | psql -h localhost -d gis -U osm

# ----------------------------------------------------------------------------------------------------------------------
#	Building mbtiles
# ----------------------------------------------------------------------------------------------------------------------

data/mbtiles:
	mkdir data/mbtiles

data/mbtiles/europe.mbtiles: data/mbtiles data/geojson/landuse.geojson data/geojson/landuse_overlay.geojson data/geojson/admin.geojson data/geojson/building.geojson data/geojson/road.geojson data/geojson/waterway.geojson data/geojson/water.geojson data/geojson/natural_label.geojson
	tippecanoe -f -o data/mbtiles/europe.mbtiles data/geojson/landuse.geojson data/geojson/landuse_overlay.geojson data/geojson/admin.geojson data/geojson/building.geojson data/geojson/road.geojson data/geojson/waterway.geojson data/geojson/water.geojson data/geojson/natural_label.geojson

data/mbtiles/mtb.mbtiles: data/mbtiles data/geojson/mtb.geojson
	tippecanoe -f -o data/mbtiles/mtb.mbtiles data/geojson/mtb.geojson

data/mbtiles/contour.mbtiles: data/mbtiles data/geojson/contour.geojson
	tippecanoe -f -o data/mbtiles/contour.mbtiles data/geojson/contour.geojson

data/mbtiles/hillshade.mbtiles: data/mbtiles data/tif/hillshade.tif
	gdal_translate data/hillshade.tif data/mbtiles/hillshade.mbtiles -of MBTILES
	gdaladdo -r nearest hillshade.mbtiles 2 4 8 16

data/mbtiles/slope.mbtiles: data/mbtiles data/tif/slope.tif
	gdal_translate data/slope.tif data/mbtiles/slope.mbtiles -of MBTILES
	gdaladdo -r nearest slope.mbtiles 2 4 8 16

# ----------------------------------------------------------------------------------------------------------------------
#	Building geojson
# ----------------------------------------------------------------------------------------------------------------------

data/geojson:
	mkdir data/geojson

data/geojson/landuse.geojson: data/geojson sql/landuse.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/landuse.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/landuse.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/landuse.geojson

data/geojson/landuse_overlay.geojson: data/geojson sql/landuse_overlay.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/landuse_overlay.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/landuse_overlay.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/landuse_overlay.geojson

data/geojson/admin.geojson: data/geojson sql/admin.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/admin.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/admin.sql

data/geojson/building.geojson: data/geojson sql/building.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/building.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/building.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/building.geojson

data/geojson/road.geojson: data/geojson data/geojson/minor_road.geojson sql/major_road.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/road.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/major_road.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/road.geojson
	ogr2ogr -f GeoJSON -append data/geojson/road.geojson data/geojson/minor_road.geojson

data/geojson/minor_road.geojson: data/geojson sql/minor_road.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/minor_road.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/minor_road.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/minor_road.geojson

data/geojson/waterway.geojson: data/geojson data/geojson/waterway_canal_stream.geojson data/geojson/waterway_ditch_drain.geojson sql/waterway_river.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_river.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' data/geojson/waterway.geojson
	ogr2ogr -f GeoJSON -append data/geojson/waterway.geojson data/geojson/waterway_canal_stream.geojson
	ogr2ogr -f GeoJSON -append data/geojson/waterway.geojson data/geojson/waterway_ditch_drain.geojson

data/geojson/waterway_canal_stream.geojson: data/geojson sql/waterway_canal_stream.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway_canal_stream.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_canal_stream.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/waterway_canal_stream.geojson

data/geojson/waterway_ditch_drain.geojson: data/geojson sql/waterway_ditch_drain.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway_ditch_drain.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_ditch_drain.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 15 },/g' data/geojson/waterway_ditch_drain.geojson

data/geojson/water.geojson: data/geojson/water_medium.geojson data/geojson/water_small.geojson sql/water_big.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_big.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' data/geojson/water.geojson
	ogr2ogr -f GeoJSON -append data/geojson/water.geojson data/geojson/water_medium.geojson
	ogr2ogr -f GeoJSON -append data/geojson/water.geojson data/geojson/water_small.geojson

data/geojson/water_medium.geojson: data/geojson sql/water_medium.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water_medium.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_medium.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' data/geojson/water_medium.geojson

data/geojson/water_small.geojson: data/geojson sql/water_small.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water_small.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_small.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/water_small.geojson

data/geojson/mtb.geojson: data/geojson sql/mtb.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/mtb.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/mtb.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 8 },/g' data/geojson/mtb.geojson

data/geojson/contour.geojson: data/geojson data/geojson/contour20.geojson data/geojson/contour100.geojson data/geojson/glacier_contour20.geojson data/geojson/glacier_contour100.geojson data/geojson/rock_contour20.geojson data/geojson/rock_contour100.geojson
	ogr2ogr -f GeoJSON data/geojson/contour.geojson data/geojson/contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour100.geojson

data/geojson/contour20.geojson: data/geojson sql/contour20.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/contour20.geojson

data/geojson/contour100.geojson: data/geojson sql/contour100.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/contour100.geojson

data/geojson/glacier_contour20.geojson: data/geojson sql/glacier_contour20.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/glacier_contour20.geojson

data/geojson/glacier_contour100.geojson: data/geojson sql/glacier_contour100.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/glacier_contour100.geojson

data/geojson/rock_contour20.geojson: data/geojson sql/rock_contour20.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/rock_contour20.geojson

data/geojson/rock_contour100.geojson: data/geojson sql/rock_contour100.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/rock_contour100.geojson

data/geojson/natural_label.geojson: data/geojson data/geojson/natural_label.geojson sql/natural_label.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/natural_label.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/natural_label.sql

# ----------------------------------------------------------------------------------------------------------------------
#	Building tifs
# ----------------------------------------------------------------------------------------------------------------------

data/tif:
	mkdir data/tif

data/tif/contour-3785-20m.tif: data/tif data/tif/contour-3785.tif
	gdal_contour -a elev -i 20 data/tif/contour-3785.tif data/tif/contour-3785-20m.tif

data/tif/slope.tif: data/tif data/tif/contour-3785.tif
	gdaldem slope data/tif/contour-3785.tif data/tif/slope.tif

data/tif/hillshade.tif: data/tif data/tif/contour-3785.tif
	gdaldem hillshade -z 5 data/tif/contour-3785.tif data/tif/hillshade.tif

data/tif/contour-3785.tif: data/tif data/tif/contour-4326.tif
	gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear data/tif/contour-4326.tif data/tif/contour-3785.tif

data/tif/contour-4326.tif: data/tif/srtm_38_03.tif data/tif/srtm_39_03.tif
	gdal_merge.py -o data/tif/contour-4326.tif data/tif/srtm_38_03.tif data/tif/srtm_39_03.tif

data/tif/srtm_38_03.tif: data/tif data/download/srtm_38_03.zip
	unzip -p data/download/srtm_38_03.zip srtm_38_03.tif > data/tif/srtm_38_03.tif

data/tif/srtm_39_03.tif: data/tif data/download/srtm_39_03.zip
	unzip -p data/download/srtm_39_03.zip srtm_39_03.tif > data/tif/srtm_39_03.tif

# ----------------------------------------------------------------------------------------------------------------------
#	Downloads
# ----------------------------------------------------------------------------------------------------------------------

data/download:
	mkdir data/download

data/download/srtm_38_03.zip: data/download
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_38_03.zip -O data/download/srtm_38_03.zip
	touch $@

data/download/srtm_39_03.zip: data/download
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_39_03.zip -O data/download/srtm_39_03.zip
	touch $@

data/download/switzerland.osm.pbf: data/download
	curl http://download.geofabrik.de/europe/switzerland-latest.osm.pbf --output data/download/switzerland.osm.pbf
	touch $@

data/download/oberbayern.osm.pbf: data/download
	curl https://download.geofabrik.de/europe/germany/bayern/oberbayern-latest.osm.pbf --output data/download/oberbayern.osm.pbf
	touch $@