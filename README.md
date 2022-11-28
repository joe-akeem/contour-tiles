# Countour Lines and Hillshade files for Europe

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

## Area

By default, the Europe area will be covered by this docker file. If your want to cover another area,
please use this tool [SRTM Tile Grabber](https://dwtkns.com/srtm/). You'll be able to identify tiles
that will be needed to build your data :

![SRTM Tile example](./img/srtmtile.png)

On this image, the name of the tile is srtm_38_03.zip. X is 38, Y is 03. For example, to compute
Africa, you can use :

* MIN_X : 33 ;
* MAX_X : 47 ;
* MIN_Y : 05 ;
* MAX_Y : 19.

Just modify the docker-compose-compute.yml so that your limits are reflected then launch the computation.

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