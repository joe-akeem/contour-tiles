all: contour mtb europe

europe: data/mbtiles/europe.mbtiles

mtb: data/mbtiles/mtb.mbtiles

contour: data/mbtiles/hillshade.mbtiles data/mbtiles/slope.mbtiles contour.mbtiles

data/mbtiles/europe.mbtiles: data/geojson/landuse.geojson data/geojson/landuse_overlay.geojson data/geojson/admin.geojson data/geojson/building.geojson data/geojson/road.geojson data/geojson/waterway.geojson data/geojson/water.geojson
	tippecanoe -f -o europe.mbtiles data/geojson/landuse.geojson data/geojson/landuse_overlay.geojson data/geojson/admin.geojson data/geojson/building.geojson data/geojson/road.geojson data/geojson/waterway.geojson data/geojson/water.geojson

data/mbtiles/mtb.mbtiles: data/geojson/mtb.geojson
	tippecanoe -f -o data/mbtiles/mtb.mbtiles data/geojson/mtb.geojson data/geojson/building.geojson

data/geojson/landuse.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/landuse.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/landuse.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/landuse.geojson

data/geojson/landuse_overlay.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/landuse_overlay.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/landuse_overlay.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/landuse_overlay.geojson

data/geojson/admin.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 admin.geojson "PG:host=localhost dbname=gis user=osm" -sql @admin.sql

data/geojson/building.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/building.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/building.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/building.geojson

data/geojson/road.geojson: shp2pgsql-osm data/geojson/minor_road.geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/road.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/major_road.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 5 },/g' data/geojson/road.geojson
	ogr2ogr -f GeoJSON -append data/geojson/road.geojson data/geojson/minor_road.geojson

data/geojson/minor_road.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/minor_road.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/inor_road.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/minor_road.geojson

data/geojson/waterway.geojson: shp2pgsql-osm data/geojson/waterway_canal_stream.geojson data/geojson/waterway_ditch_drain.geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_river.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' data/geojson/waterway.geojson
	ogr2ogr -f GeoJSON -append data/geojson/waterway.geojson data/geojson/waterway_canal_stream.geojson
	ogr2ogr -f GeoJSON -append data/geojson/waterway.geojson data/geojson/waterway_ditch_drain.geojson

data/geojson/waterway_canal_stream.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway_canal_stream.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_canal_stream.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/waterway_canal_stream.geojson

data/geojson/waterway_ditch_drain.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/waterway_ditch_drain.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/waterway_ditch_drain.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 15 },/g' data/geojson/waterway_ditch_drain.geojson

data/geojson/water.geojson: shp2pgsql-osm data/geojson/water_medium.geojson data/geojson/water_small.geojson
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_big.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 0 },/g' data/geojson/water.geojson
	ogr2ogr -f GeoJSON -append data/geojson/water.geojson data/geojson/water_medium.geojson
	ogr2ogr -f GeoJSON -append data/geojson/water.geojson data/geojson/water_small.geojson

data/geojson/water_medium.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water_medium.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_medium.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 7 },/g' data/geojson/water_medium.geojson

data/geojson/water_small.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/water_small.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/water_small.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/water_small.geojson

data/geojson/mtb.geojson: shp2pgsql-osm
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/mtb.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/mtb.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 8 },/g' data/geojson/mtb.geojson

data/mbtiles/contour.mbtiles: data/geojson/contour.geojson
	tippecanoe -f -o data/mbtiles/contour.mbtiles data/geojson/contour.geojson

data/geojson/contour.geojson: data/geojson/contour20.geojson data/geojson/contour100.geojson data/geojson/glacier_contour20.geojson data/geojson/glacier_contour100.geojson data/geojson/rock_contour20.geojson data/geojson/rock_contour100.geojson
	ogr2ogr -f GeoJSON data/geojson/contour.geojson data/geojson/contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour100.geojson

data/geojson/contour20.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/contour20.geojson

data/geojson/contour100.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/contour100.geojson

data/geojson/glacier_contour20.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/glacier_contour20.geojson

data/geojson/glacier_contour100.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/glacier_contour100.geojson

data/geojson/rock_contour20.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/rock_contour20.geojson

data/geojson/rock_contour100.geojson: shp2pgsql-contour
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/rock_contour100.geojson

shp2pgsql-contour: data/contour-3785-20m.tif
#	shp2pgsql -s 3857 data/contour-3785-20m.tif/contour.shp contourlines | psql -h localhost -d gis -U osm

shp2pgsql-osm:
#	TODO

data/contour-3785-20m.tif: data/contour-3785.tif
	gdal_contour -a elev -i 20 data/contour-3785.tif data/contour-3785-20m.tif

data/mbtiles/hillshade.mbtiles: data/hillshade.tif
	gdal_translate data/hillshade.tif data/mbtiles/hillshade.mbtiles -of MBTILES
	gdaladdo -r nearest hillshade.mbtiles 2 4 8 16

data/mbtiles/slope.mbtiles: data/slope.tif
	gdal_translate data/slope.tif data/mbtiles/slope.mbtiles -of MBTILES
	gdaladdo -r nearest slope.mbtiles 2 4 8 16

data/slope.tif: data/contour-3785.tif
	gdaldem slope data/contour-3785.tif data/slope.tif

data/hillshade.tif: data/contour-3785.tif
	gdaldem hillshade -z 5 data/contour-3785.tif data/hillshade.tif

data/contour-3785.tif: data/contour-4326.tif
	gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear data/contour-4326.tif data/contour-3785.tif

data/contour-4326.tif: data/srtm_38_03.tif data/srtm_39_03.zip
	gdal_merge.py -o data/contour-4326.tif data/srtm_38_03.tif data/srtm_39_03.tif

data/srtm_38_03.tif: data/srtm_38_03.zip
	unzip -p data/srtm_38_03.zip srtm_38_03.tif > data/srtm_38_03.tif

data/srtm_39_03.tif: data/srtm_39_03.zip
	unzip -p srtm_39_03.zip srtm_39_03.tif > srtm_39_03.tif

data/srtm_38_03.zip:
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_38_03.zip -O data/srtm_38_03.zip

data/srtm_39_03.zip:
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_39_03.zip -O data/srtm_39_03.zip