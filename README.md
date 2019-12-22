# Countour Lines and Hillshade files for Europe

A docker image to create vector tiles for contour lines and hillshade raster tiles of europe (mbtiles files).

## Getting it
```bash
git clone https://github.com/joe-akeem/contour-tiles.git
```

## Building the mbtiles files

```bash
cd contour-tiles
docker-compose run contour-tiles
```

This will build the mbtiles files in the folder `./osm/mbtiles`

## Inspecting the tiles

To inspect the mbtiles files a local tileserver can be started as follows:

```bash
docker-compose up -d contour-tileserver
```

You will notice that there are contour lines for 100 meter and for 20 meter equidistance. The 100 meter equidistance
will start showing from zoom level 10 while the 20 meter equidistance lines start showing from zoom level 13 upwards.
 
The contour lines are tagged with two fields:
* `elev: the elevation of the contour line in meters above sea level
* `distance: the equidistance of the contour line (20m or 100m) which helps styling them differently. E.g.you might want
  to show the 100 meter lines more prominent.
* `type`: this is currently `normal` for all contour lines. There are plans to encode the terrain in this field
  (e.g. `normal`, `rock`, `glacier`) so you can style the lines differently depending on the terrain (e.g. blue for glaciers).
