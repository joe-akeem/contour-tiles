all: contour

contour: data/mbtiles/hillshade.mbtiles data/mbtiles/slope.mbtiles contour.mbtiles

data/mbtiles/contour.mbtiles: data/geojson/contour.geojson
	tippecanoe -f -o data/mbtiles/contour.mbtiles data/geojson/contour.geojson

data/geojson/contour.geojson: data/geojson/contour20.geojson data/geojson/contour100.geojson data/geojson/glacier_contour20.geojson data/geojson/glacier_contour100.geojson data/geojson/rock_contour20.geojson data/geojson/rock_contour100.geojson
	ogr2ogr -f GeoJSON data/geojson/contour.geojson data/geojson/contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/glacier_contour100.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour20.geojson
	ogr2ogr -f GeoJSON -append data/geojson/contour.geojson data/geojson/rock_contour100.geojson

data/geojson/contour20.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/contour20.geojson

data/geojson/contour100.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/contour100.geojson

data/geojson/glacier_contour20.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/glacier_contour20.geojson

data/geojson/glacier_contour100.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/glacier_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/glacier_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/glacier_contour100.geojson

data/geojson/rock_contour20.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour20.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour20.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' data/geojson/rock_contour20.geojson

data/geojson/rock_contour100.geojson: shp2pgsql
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 data/geojson/rock_contour100.geojson "PG:host=localhost dbname=gis user=osm" -sql @sql/rock_contour100.sql
	sed -i '' 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' data/geojson/rock_contour100.geojson

shp2pgsql: data/contour-3785-20m.tif
#	shp2pgsql -s 3857 data/contour-3785-20m.tif/contour.shp contourlines | psql -h localhost -d gis -U osm

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