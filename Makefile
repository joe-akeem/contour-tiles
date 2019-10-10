# ----------------------------------------------------------------------------------------------------------------------
#	Main Targets
# ----------------------------------------------------------------------------------------------------------------------

all: contour mtb europe docs

europe: /data/mbtiles/europe.mbtiles

mtb: /data/mbtiles/mtb.mbtiles

contour: /data/mbtiles/hillshade.mbtiles /data/mbtiles/slope.mbtiles /data/mbtiles/contour.mbtiles /data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles

docs:
	cd /docs && make html

# ----------------------------------------------------------------------------------------------------------------------
#	Building mbtiles
# ----------------------------------------------------------------------------------------------------------------------

/data/mbtiles/europe.mbtiles: /data/geojson/landuse.geojson /data/geojson/landuse_overlay.geojson /data/geojson/admin.geojson /data/geojson/building.geojson /data/geojson/road.geojson /data/geojson/waterway.geojson /data/geojson/water.geojson /data/geojson/natural_label.geojson /data/geojson/place_label.geojson /data/geojson/poi_label.geojson /data/geojson/aeroway.geojson /data/geojson/airport_label.geojson
	mkdir -p /data/mbtiles
	tippecanoe -f -o /data/mbtiles/europe.mbtiles --drop-densest-as-needed /data/geojson/landuse.geojson /data/geojson/landuse_overlay.geojson /data/geojson/admin.geojson /data/geojson/building.geojson /data/geojson/road.geojson /data/geojson/waterway.geojson /data/geojson/water.geojson /data/geojson/natural_label.geojson /data/geojson/place_label.geojson /data/geojson/poi_label.geojson /data/geojson/aeroway.geojson /data/geojson/airport_label.geojson

/data/mbtiles/mtb.mbtiles: /data/geojson/mtb.geojson
	mkdir -p /data/mbtiles
	tippecanoe -f -o /data/mbtiles/mtb.mbtiles /data/geojson/mtb.geojson

/data/mbtiles/contour.mbtiles: /data/geojson/contour.geojson
	mkdir -p /data/mbtiles
	tippecanoe -f -o /data/mbtiles/contour.mbtiles /data/geojson/contour.geojson

/data/mbtiles/hillshade.mbtiles: /data/tif/hillshade.tif
	mkdir -p /data/mbtiles
	gdal_translate /data/tif/hillshade.tif /data/mbtiles/hillshade.mbtiles -of MBTILES
	gdaladdo -r nearest /data/mbtiles/hillshade.mbtiles 2 4 8 16

/data/mbtiles/slope.mbtiles: /data/tif/slope.tif
	mkdir -p /data/mbtiles
	gdal_translate /data/tif/slope.tif /data/mbtiles/slope.mbtiles -of MBTILES
	gdaladdo -r nearest /data/mbtiles/slope.mbtiles 2 4 8 16

/data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles:
	curl https://download.openslopemap.org/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles --output /data/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building geojson
# ----------------------------------------------------------------------------------------------------------------------

/data/geojson/landuse.geojson: /data/load-europe /sql/landuse.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/landuse.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/landuse.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' /data/geojson/landuse.geojson

/data/geojson/landuse_overlay.geojson: /data/load-europe /sql/landuse_overlay.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/landuse_overlay.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/landuse_overlay.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' /data/geojson/landuse_overlay.geojson

/data/geojson/admin.geojson: /data/load-europe /sql/admin.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/admin.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/admin.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' /data/geojson/admin.geojson

/data/geojson/building.geojson: /data/load-europe /sql/building.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/building.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/building.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/building.geojson

/data/geojson/road.geojson: /data/load-europe /data/geojson/minor_road.geojson /sql/major_road.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/road.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/major_road.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' /data/geojson/road.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/road.geojson /data/geojson/minor_road.geojson

/data/geojson/minor_road.geojson: /data/load-europe /sql/minor_road.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/minor_road.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/minor_road.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/minor_road.geojson

/data/geojson/waterway.geojson: /data/load-europe /data/geojson/waterway_canal_stream.geojson /data/geojson/waterway_ditch_drain.geojson /sql/waterway_river.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/waterway.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/waterway_river.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' /data/geojson/waterway.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/waterway.geojson /data/geojson/waterway_canal_stream.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/waterway.geojson /data/geojson/waterway_ditch_drain.geojson

/data/geojson/waterway_canal_stream.geojson: /data/load-europe /sql/waterway_canal_stream.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/waterway_canal_stream.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/waterway_canal_stream.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/waterway_canal_stream.geojson

/data/geojson/waterway_ditch_drain.geojson: /data/load-europe /sql/waterway_ditch_drain.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/waterway_ditch_drain.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/waterway_ditch_drain.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 15 },/g' /data/geojson/waterway_ditch_drain.geojson

/data/geojson/water.geojson: /data/load-europe /data/geojson/water_medium.geojson /data/geojson/water_small.geojson /sql/water_big.sql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/water.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/water_big.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' /data/geojson/water.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/water.geojson /data/geojson/water_medium.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/water.geojson /data/geojson/water_small.geojson

/data/geojson/water_medium.geojson: /data/load-europe /sql/water_medium.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/water_medium.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/water_medium.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' /data/geojson/water_medium.geojson

/data/geojson/water_small.geojson: /data/load-europe /sql/water_small.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/water_small.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/water_small.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/water_small.geojson

/data/geojson/mtb.geojson: /data/load-europe /sql/mtb.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/mtb.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/mtb.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 8 },/g' /data/geojson/mtb.geojson

/data/geojson/contour.geojson: /data/geojson/contour20.geojson /data/geojson/contour100.geojson /data/geojson/glacier_contour20.geojson /data/geojson/glacier_contour100.geojson /data/geojson/rock_contour100.geojson #/data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON /data/geojson/contour.geojson /data/geojson/contour20.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/contour100.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/glacier_contour20.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/glacier_contour100.geojson
	#ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON -append /data/geojson/contour.geojson /data/geojson/rock_contour100.geojson

/data/geojson/contour20.geojson: /data/shp2pgsql-contour /sql/contour20.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/contour20.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/contour20.geojson

/data/geojson/contour100.geojson: /data/shp2pgsql-contour /sql/contour100.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/contour100.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/contour100.geojson

/data/geojson/glacier_contour20.geojson: /data/shp2pgsql-contour /sql/glacier_contour20.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/glacier_contour20.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/glacier_contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/glacier_contour20.geojson

/data/geojson/glacier_contour100.geojson: /data/shp2pgsql-contour /sql/glacier_contour100.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/glacier_contour100.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/glacier_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/glacier_contour100.geojson

/data/geojson/rock_contour20.geojson: /data/shp2pgsql-contour /sql/rock_contour20.sql
	mkdir -p /data/geojson
	#ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/rock_contour20.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/rock_contour20.sql
	#sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' /data/geojson/rock_contour20.geojson

/data/geojson/rock_contour100.geojson: /data/shp2pgsql-contour /sql/rock_contour100.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/rock_contour100.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/rock_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' /data/geojson/rock_contour100.geojson

/data/geojson/natural_label.geojson: /data/load-europe /sql/natural_label.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/natural_label.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/natural_label.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' /data/geojson/natural_label.geojson

/data/geojson/place_label.geojson: /data/load-europe /sql/place_label.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/place_label.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/place_label.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' /data/geojson/place_label.geojson

/data/geojson/poi_label.geojson: /data/load-europe /sql/poi_label.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/poi_label.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/poi_label.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' /data/geojson/poi_label.geojson

/data/geojson/aeroway.geojson: /data/load-europe /sql/aeroway.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/aeroway.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/aeroway.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 9 },/g' /data/geojson/aeroway.geojson

/data/geojson/airport_label.geojson: /data/load-europe /sql/airport_label.sql
	mkdir -p /data/geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 /data/geojson/airport_label.geojson "PG:host=$$PG_PORT_5432_TCP_ADDR port=$$PG_PORT_5432_TCP_PORT dbname=gis user=osm" -sql @/sql/airport_label.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 9 },/g' /data/geojson/airport_label.geojson

# ----------------------------------------------------------------------------------------------------------------------
# Loading the database
# ----------------------------------------------------------------------------------------------------------------------

#/data/load-europe: /data/download/europe.osm.pbf
/data/load-europe: /data/download/switzerland.osm.pbf
	#osm2pgsql --create --slim --cache 2000 --host $$PG_PORT_5432_TCP_ADDR --port $$PG_PORT_5432_TCP_PORT --username osm --database gis --hstore-column mtb /osm/data/download/europe.osm.pbf
	osm2pgsql --create --slim --host $$PG_PORT_5432_TCP_ADDR --port $$PG_PORT_5432_TCP_PORT --username osm --database gis --hstore-column mtb /data/download/switzerland.osm.pbf
	touch /data/load-europe

/data/shp2pgsql-contour: /data/tif/contour-3785-20m.tif
	/bin/bash -c 'shp2pgsql -s 3857 /data/tif/contour-3785-20m.tif/contour.shp contourlines | psql -h $$PG_PORT_5432_TCP_ADDR -p $$PG_PORT_5432_TCP_PORT -d gis -U osm'
	touch /data/shp2pgsql-contour

# ----------------------------------------------------------------------------------------------------------------------
#	Building tifs
# ----------------------------------------------------------------------------------------------------------------------

/data/tif/contour-3785-20m.tif: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdal_contour -a elev -i 20 /data/tif/contour-3785.tif /data/tif/contour-3785-20m.tif

/data/tif/slope.tif: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdaldem slope /data/tif/contour-3785.tif /data/tif/slope.tif

/data/tif/hillshade.tif: /data/tif/contour-3785.tif
	mkdir -p /data/tif
	gdaldem hillshade -z 5 /data/tif/contour-3785.tif /data/tif/hillshade.tif

/data/tif/contour-3785.tif: /data/tif/contour-4326.tif
	mkdir -p /data/tif
	gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear /data/tif/contour-4326.tif /data/tif/contour-3785.tif

/data/tif/contour-4326.tif: /data/tif/srtm_38_03.tif /data/tif/srtm_39_03.tif
	gdal_merge.py -o /data/tif/contour-4326.tif /data/tif/srtm_38_03.tif /data/tif/srtm_39_03.tif

/data/tif/srtm_38_03.tif: /data/download/srtm_38_03.zip
	mkdir -p /data/tif
	unzip -p /data/download/srtm_38_03.zip srtm_38_03.tif > /data/tif/srtm_38_03.tif

/data/tif/srtm_39_03.tif: /data/download/srtm_39_03.zip
	mkdir -p /data/tif
	unzip -p /data/download/srtm_39_03.zip srtm_39_03.tif > /data/tif/srtm_39_03.tif

# ----------------------------------------------------------------------------------------------------------------------
#	Downloads
# ----------------------------------------------------------------------------------------------------------------------

/data/download/srtm_38_03.zip:
	mkdir -p /data/download
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_38_03.zip -O /data/download/srtm_38_03.zip
	touch $@

/data/download/srtm_39_03.zip:
	mkdir -p /data/download
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_39_03.zip -O /data/download/srtm_39_03.zip
	touch $@

/data/download/switzerland.osm.pbf:
	mkdir -p /data/download
	curl http://download.geofabrik.de/europe/switzerland-latest.osm.pbf --output /data/download/switzerland.osm.pbf
	touch $@

/data/download/oberbayern.osm.pbf:
	mkdir -p /data/download
	curl https://download.geofabrik.de/europe/germany/bayern/oberbayern-latest.osm.pbf --output /data/download/oberbayern.osm.pbf
	touch $@

/data/download/europe.osm.pbf:
	mkdir -p /data/download
	wget https://download.geofabrik.de/europe-latest.osm.pbf -O /data/download/europe.osm.pbf