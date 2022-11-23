# Countour Lines and Hillshade files for Europe (and other Regions)

A docker image to create vector tiles for contour lines and hillshade (relief) raster tiles of europe (mbtiles files).

The relief and is based on data from [SRTM 90m DEM Digital Elevation Database](http://srtm.csi.cgiar.org) and
[OpenSlopeMap](https://www.openslopemap.org/).

## Getting it
```bash
git clone https://github.com/joe-akeem/contour-tiles.git
```

## Building the mbtiles files

```bash
cd contour-tiles
docker-compose -f docker-compose-compute.yml build contour-tiles && docker-compose -f docker-compose-compute.yml up
```

This will build the mbtiles files in the folder `./osm/mbtiles`

## Inspecting the tiles

To inspect the mbtiles files a local tileserver can be started as follows:

```bash
docker-compose up
```
The web interface of the tile server is made available at [localhost:8080](http://localhost:8080).
A basic style is also available and can be used to view the generated data e.g. as [Vector Tiles](http://localhost:8080/styles/basic/?vector#13.57/46.49646/8.61135).

You will notice that there are contour lines for 100 meter and for 20 meter equidistance. The 100 meter equidistance lines
will start showing from zoom level 10 while the 20 meter equidistance lines are showing from zoom level 13 upwards.
 
The contour lines are tagged with three fields:
* `elev`: the elevation of the contour line in meters above sea level
* `distance: the equidistance of the contour line (20m or 100m) which helps styling them differently. E.g. you might want
  to show the 100 meter lines more prominent.
* `type`: this is currently `normal` for all contour lines. There are plans to encode the terrain in this field
  (e.g. `normal`, `rock`, `glacier`) so you can style the lines differently depending on the terrain (e.g. blue for glaciers).

![Relief with contour lines](./img/relief.png)

## Performances

The container has been tried with success on an Azure VM, Standard_D8ds_v5 with
a P30 SSD (1To, 5kIOPS). The whole process took about 45 minutes.

## Building other Regions of the World

Currently, the area to build (europe) is hard-coded in the `Makefile`. So this is not very generic at the moment. However,
as an interim workaround to build other areas of the world, the list of files that makes up `contour-4326.tif` can simply
be changed in the `Makefile`. To identify the files that need to be downloaded, visit https://srtm.csi.cgiar.org/srtmdata/,
select the tiles you need in 5x5 degree size and hit `search`. The page that follows is the list of zip files that need
to be downloaded.

For example, to build contour tile for the Andes, replace

``` make
$(TIFDIR)/contour-4326.tif: $(TIFDIR)/srtm_34_02.tif \
                            $(TIFDIR)/srtm_35_01.tif \
                            $(TIFDIR)/srtm_35_02.tif \
                            #etc.
```

by

``` make
$(TIFDIR)/contour-4326.tif: $(TIFDIR)/srtm_21_13.tif \
                            $(TIFDIR)/srtm_21_14.tif \
                            $(TIFDIR)/srtm_21_15.tif \
                            $(TIFDIR)/srtm_22_15.tif \
                            #etc.
```

Don't forget to re-build the container after the modification!
