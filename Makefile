PG_TCP_PORT := 5432
PG_TCP_ADDR := postgres-osm
PG_USER := contour
PG_PASS := passwd

TIFDIR := /data/tif
DOWNLOADDIR := /data/download
GEOJSONDIR := /data/geojson
MBTILESDIR := /data/mbtiles
LARGETMPDIR := /data/tmp

DESCRIPTION := ${DESCRIPTION}
ATTRIBUTION := ${ATTRIBUTION}

MIN_X := ${MIN_X}
MAX_X := ${MAX_X}
MIN_Y := ${MIN_Y}
MAX_Y := ${MAX_Y}
MIN_Z := ${MIN_Z}
MAX_Z := ${MAX_Z}

CONTOUR_JOBS := ${CONTOUR_JOBS}
GDAL_CACHEMAX := ${GDAL_CACHEMAX}

GDAL_COMPRESS_OPTIONS := -co COMPRESS=LZW -co BIGTIFF=YES -co PREDICTOR=2 -co TILED=YES

# ----------------------------------------------------------------------------------------------------------------------
#	Main Targets
# ----------------------------------------------------------------------------------------------------------------------

all: $(MBTILESDIR)/hillshade.mbtiles $(MBTILESDIR)/slope.mbtiles $(MBTILESDIR)/contour.mbtiles $(MBTILESDIR)/OSloOVERLAY_LR_Alps_16.mbtiles

# ----------------------------------------------------------------------------------------------------------------------
#	Building mbtiles
# ----------------------------------------------------------------------------------------------------------------------

$(MBTILESDIR)/contour.mbtiles: $(GEOJSONDIR)/contour.geojson
	mkdir -p $(MBTILESDIR)
	mkdir -p $(LARGETMPDIR)
	tippecanoe -t $(LARGETMPDIR) -f -Z10 -o $@ --no-tile-stats --description "$(DESCRIPTION)" --attribution "$(ATTRIBUTION)" -l contour $(GEOJSONDIR)/contour*0.geojson

$(MBTILESDIR)/hillshade.mbtiles: $(TIFDIR)/hillshade.tif
	mkdir -p $(MBTILESDIR)
	gdal_translate --config GDAL_CACHEMAX $(GDAL_CACHEMAX) $< $@ -of MBTILES
	gdaladdo -r nearest $@ 2 4 8 16

$(MBTILESDIR)/slope.mbtiles: $(TIFDIR)/slope.tif
	mkdir -p $(MBTILESDIR)
	gdal_translate --config GDAL_CACHEMAX $(GDAL_CACHEMAX) $< $@ -of MBTILES
	gdaladdo -r nearest $@ 2 4 8 16

$(MBTILESDIR)/OSloOVERLAY_LR_Alps_16.mbtiles:
	curl https://download.openslopemap.org/mbtiles/OSloOVERLAY_LR_Alps_16.mbtiles --output $@

# ----------------------------------------------------------------------------------------------------------------------
#	Building geojson
# ----------------------------------------------------------------------------------------------------------------------

$(GEOJSONDIR)/contour.geojson: $(TIFDIR)/contour.tif
	mkdir -p $(GEOJSONDIR)
	seq $(MIN_Z) 20 $(MAX_Z) | parallel --jobs $(CONTOUR_JOBS) gdal_contour -f GeoJSON -nln contourlines -a elev -fl {1} $< $(GEOJSONDIR)/contour{1}.geojson
	seq $(MIN_Z) 100 $(MAX_Z) | parallel 'sed -i "s/\"type\": \"Feature\",/\"type\": \"Feature\", \"tippecanoe\" : { \"minzoom\": 10 },/g" $(GEOJSONDIR)/contour{1}.geojson'
	seq $$(( $(MIN_Z) + 20 )) 100 $(MAX_Z) | parallel --jobs $(CONTOUR_JOBS) 'sed -i "s/\"type\": \"Feature\",/\"type\": \"Feature\", \"tippecanoe\" : { \"minzoom\": 13 },/g" $(GEOJSONDIR)/contour{1}.geojson'
	seq $$(( $(MIN_Z) + 40 )) 100 $(MAX_Z) | parallel --jobs $(CONTOUR_JOBS) 'sed -i "s/\"type\": \"Feature\",/\"type\": \"Feature\", \"tippecanoe\" : { \"minzoom\": 13 },/g" $(GEOJSONDIR)/contour{1}.geojson'
	seq $$(( $(MIN_Z) + 60 )) 100 $(MAX_Z) | parallel --jobs $(CONTOUR_JOBS) 'sed -i "s/\"type\": \"Feature\",/\"type\": \"Feature\", \"tippecanoe\" : { \"minzoom\": 13 },/g" $(GEOJSONDIR)/contour{1}.geojson'
	seq $$(( $(MIN_Z) + 80 )) 100 $(MAX_Z) | parallel --jobs $(CONTOUR_JOBS) 'sed -i "s/\"type\": \"Feature\",/\"type\": \"Feature\", \"tippecanoe\" : { \"minzoom\": 13 },/g" $(GEOJSONDIR)/contour{1}.geojson'
	touch $@

$(GEOJSONDIR)/glacier_contour20.geojson: /data/contour2pgsql-contour /sql/glacier_contour20.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:4326 $(GEOJSONDIR)/glacier_contour20.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' $(GEOJSONDIR)/glacier_contour20.geojson

$(GEOJSONDIR)/glacier_contour100.geojson: /data/contour2pgsql-contour /sql/glacier_contour100.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:4326 $(GEOJSONDIR)/glacier_contour100.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/glacier_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' $(GEOJSONDIR)/glacier_contour100.geojson

$(GEOJSONDIR)/rock_contour20.geojson: /data/contour2pgsql-contour /sql/rock_contour20.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:4326 $(GEOJSONDIR)/rock_contour20.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour20.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 13 },/g' $(GEOJSONDIR)/rock_contour20.geojson

$(GEOJSONDIR)/rock_contour100.geojson: /data/contour2pgsql-contour /sql/rock_contour100.sql
	mkdir -p $(GEOJSONDIR)
	ogr2ogr -f GeoJSON -t_srs EPSG:4326 -s_srs EPSG:4326 $(GEOJSONDIR)/rock_contour100.geojson "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)" -sql @/sql/rock_contour100.sql
	sed -i 's/"type": "Feature",/"type": "Feature", "tippecanoe" : { "minzoom": 10 },/g' $(GEOJSONDIR)/rock_contour100.geojson

# ----------------------------------------------------------------------------------------------------------------------
# Loading the database
# ----------------------------------------------------------------------------------------------------------------------

/data/contour2pgsql-contour: $(TIFDIR)/contour.tif
	PGPASSWORD=$(PG_PASS) psql -h $(PG_TCP_ADDR) -p $(PG_TCP_PORT) -U $(PG_USER) -d gis -c "DROP TABLE IF EXISTS contourlines;"       
	gdal_contour -f PostgreSQL -nln contourlines -a elev -i 20 $< "PG:host=$(PG_TCP_ADDR) port=$(PG_TCP_PORT) dbname=gis user=$(PG_USER) password=$(PG_PASS)"
	touch /data/contour2pgsql-contour
	
# ----------------------------------------------------------------------------------------------------------------------
#	Building tifs
# ----------------------------------------------------------------------------------------------------------------------

$(TIFDIR)/slope.tif: $(TIFDIR)/contour.tif
	mkdir -p $(TIFDIR)
	gdaldem slope $< $@

$(TIFDIR)/hillshade.tif: $(TIFDIR)/contour.tif
	mkdir -p $(TIFDIR)
	gdaldem hillshade -z 5 $< $@

$(TIFDIR)/contour.tif:
	mkdir -p $(DOWNLOADDIR)
	mkdir -p $(TIFDIR)

	for x in $$(seq -f "%02g" $(MIN_X) $(MAX_X)) ; do \
		for y in $$(seq -f "%02g" $(MIN_Y) $(MAX_Y)) ; do \
			wget http://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_$${x}_$${y}.zip --no-check-certificate -O $(DOWNLOADDIR)/srtm_$${x}_$${y}.zip; \
			unzip -p $(DOWNLOADDIR)/srtm_$${x}_$${y}.zip *.tif > $(TIFDIR)/srtm_$${x}_$${y}.tif; \
			rm $(DOWNLOADDIR)/srtm_$${x}_$${y}.zip; \
		done; \
		gdal_merge.py $(GDAL_COMPRESS_OPTIONS) -o $(TIFDIR)/contour-$${x}.tif $(TIFDIR)/srtm_$${x}_*.tif; \
		rm $(TIFDIR)/srtm_$${x}_*.tif; \
	done; \
	echo merge
	gdal_merge.py $(GDAL_COMPRESS_OPTIONS) -o $@ $(TIFDIR)/contour-*.tif
	rm $(TIFDIR)/contour-*.tif;
	