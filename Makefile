PG_TCP_PORT := 5432
PG_TCP_ADDR := postgres-osm
PG_USER := contour
PG_PASS := passwd

TIFDIR := /data/tif
DOWNLOADDIR := /data/download
GEOJSONDIR := /data/geojson
MBTILESDIR := /data/mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Main Targets
# ----------------------------------------------------------------------------------------------------------------------

all: $(MBTILESDIR)/hillshade.mbtiles $(MBTILESDIR)/slope.mbtiles $(MBTILESDIR)/contour.mbtiles $(MBTILESDIR)/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building mbtiles
# ----------------------------------------------------------------------------------------------------------------------

$(MBTILESDIR)/contour.mbtiles: $(GEOJSONDIR)/contour.geojson
	mkdir -p $(MBTILESDIR)
	tippecanoe -f -o $(MBTILESDIR)/contour.mbtiles --no-tile-stats --description "Europe contour lines vector data by singletrail-map.eu" --attribution "©singletrail-map.eu ©OpenStreetMap" $(GEOJSONDIR)/contour.geojson

$(MBTILESDIR)/hillshade.mbtiles: $(TIFDIR)/hillshade.tif
	mkdir -p $(MBTILESDIR)
	gdal_translate $(TIFDIR)/hillshade.tif $(MBTILESDIR)/hillshade.mbtiles -of MBTILES
	gdaladdo -r nearest $(MBTILESDIR)/hillshade.mbtiles 2 4 8 16

$(MBTILESDIR)/slope.mbtiles: $(TIFDIR)/slope.tif
	mkdir -p $(MBTILESDIR)
	gdal_translate $(TIFDIR)/slope.tif $(MBTILESDIR)/slope.mbtiles -of MBTILES
	gdaladdo -r nearest $(MBTILESDIR)/slope.mbtiles 2 4 8 16

$(MBTILESDIR)/OSloOVERLAY_LR_Alps_16.mbtiles:
	curl https://download.openslopemap.org/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles --output $(MBTILESDIR)/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building geojson
# ----------------------------------------------------------------------------------------------------------------------

$(GEOJSONDIR)/contour.geojson: $(GEOJSONDIR)/contour20.geojson $(GEOJSONDIR)/contour100.geojson
	ogr2ogr -f GeoJSON $(GEOJSONDIR)/contour.geojson $(GEOJSONDIR)/contour20.geojson
	ogr2ogr -f GeoJSON -append $(GEOJSONDIR)/contour.geojson $(GEOJSONDIR)/contour100.geojson

$(GEOJSONDIR)/contour20.geojson: /data/contour2pgsql-contour /sql/contour20.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/contour20.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' $(GEOJSONDIR)/contour20.geojson

$(GEOJSONDIR)/contour100.geojson: /data/contour2pgsql-contour /sql/contour100.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/contour100.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' $(GEOJSONDIR)/contour100.geojson

$(GEOJSONDIR)/glacier_contour20.geojson: /data/contour2pgsql-contour /sql/glacier_contour20.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/glacier_contour20.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' $(GEOJSONDIR)/glacier_contour20.geojson

$(GEOJSONDIR)/glacier_contour100.geojson: /data/contour2pgsql-contour /sql/glacier_contour100.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/glacier_contour100.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' $(GEOJSONDIR)/glacier_contour100.geojson

$(GEOJSONDIR)/rock_contour20.geojson: /data/contour2pgsql-contour /sql/rock_contour20.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/rock_contour20.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' $(GEOJSONDIR)/rock_contour20.geojson

$(GEOJSONDIR)/rock_contour100.geojson: /data/contour2pgsql-contour /sql/rock_contour100.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:3857 $(GEOJSONDIR)/rock_contour100.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' $(GEOJSONDIR)/rock_contour100.geojson

# ----------------------------------------------------------------------------------------------------------------------
# Loading the database
# ----------------------------------------------------------------------------------------------------------------------

/data/contour2pgsql-contour: $(TIFDIR)/contour-3785.tif
	PGPASSWORD=$(PG_PASS) psql -h $(PG_TCP_ADDR) -p $(PG_TCP_PORT) -U $(PG_USER) -d gis -c "DROP TABLE IF EXISTS contourlines;"       
	gdal_contour -f PostgreSQL -nln contourlines -a elev -i 20 $(TIFDIR)/contour-3785.tif "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)"
	touch /data/contour2pgsql-contour

# ----------------------------------------------------------------------------------------------------------------------
#	Building tifs
# ----------------------------------------------------------------------------------------------------------------------

$(TIFDIR)/slope.tif: $(TIFDIR)/contour-3785.tif
	mkdir -p $(TIFDIR)
	gdaldem slope $(TIFDIR)/contour-3785.tif $(TIFDIR)/slope.tif

$(TIFDIR)/hillshade.tif: $(TIFDIR)/contour-3785.tif
	mkdir -p $(TIFDIR)
	gdaldem hillshade -z 5 $(TIFDIR)/contour-3785.tif $(TIFDIR)/hillshade.tif

$(TIFDIR)/contour-3785.tif: $(TIFDIR)/contour-4326.tif
	mkdir -p $(TIFDIR)
	gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear $(TIFDIR)/contour-4326.tif $(TIFDIR)/contour-3785.tif

$(TIFDIR)/contour-4326.tif: $(TIFDIR)/srtm_34_02.tif \
							$(TIFDIR)/srtm_35_01.tif \
							$(TIFDIR)/srtm_35_02.tif \
							$(TIFDIR)/srtm_35_03.tif \
							$(TIFDIR)/srtm_35_04.tif \
							$(TIFDIR)/srtm_35_05.tif \
							$(TIFDIR)/srtm_36_01.tif \
							$(TIFDIR)/srtm_36_02.tif \
							$(TIFDIR)/srtm_36_03.tif \
							$(TIFDIR)/srtm_36_04.tif \
							$(TIFDIR)/srtm_36_05.tif \
 							$(TIFDIR)/srtm_37_01.tif \
 							$(TIFDIR)/srtm_37_02.tif \
 							$(TIFDIR)/srtm_37_03.tif \
 							$(TIFDIR)/srtm_37_04.tif \
 							$(TIFDIR)/srtm_37_05.tif \
 							$(TIFDIR)/srtm_38_01.tif \
 							$(TIFDIR)/srtm_38_02.tif \
 							$(TIFDIR)/srtm_38_03.tif \
 							$(TIFDIR)/srtm_38_04.tif \
 							$(TIFDIR)/srtm_38_05.tif \
 							$(TIFDIR)/srtm_39_01.tif \
 							$(TIFDIR)/srtm_39_02.tif \
 							$(TIFDIR)/srtm_39_03.tif \
 							$(TIFDIR)/srtm_39_04.tif \
 							$(TIFDIR)/srtm_39_05.tif \
 							$(TIFDIR)/srtm_40_01.tif \
 							$(TIFDIR)/srtm_40_02.tif \
 							$(TIFDIR)/srtm_40_03.tif \
 							$(TIFDIR)/srtm_40_04.tif \
 							$(TIFDIR)/srtm_40_05.tif
	gdal_merge.py -o $@ $^

$(TIFDIR)/srtm_%.tif: $(DOWNLOADDIR)/srtm_%.zip
	mkdir -p $(TIFDIR)
	unzip -p $< *.tif > $@


# ----------------------------------------------------------------------------------------------------------------------
#	Downloads
# ----------------------------------------------------------------------------------------------------------------------

$(DOWNLOADDIR)/srtm_%.zip:
	mkdir -p $(DOWNLOADDIR)
	base_name=$(shell basename $@)
	wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/$(shell basename $@) --no-check-certificate -O $@
	touch $@