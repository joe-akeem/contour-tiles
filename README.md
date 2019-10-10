# Singletrailmap Tileserver

#Building and deploying the tileserver docker image
```bash
docker build -t joeakeem/tileserver:latest .
docker push joeakeem/tileserver:latest
```

#Running PostGIS

Run PostGIS in a new container on port 25432
```bash
# OLD docker run --name osmdb -e POSTGRES_USER=osm -e POSTGRES_PASS=osm -e POSTGRES_DBNAME=gis -e POSTGRES_MULTIPLE_EXTENSIONS=postgis,hstore -p 25432:5432 -d -t kartoza/postgis
docker run -d --name postgres-osm -p 25432:5432 openfirmware/postgres-osm
``` 

Stopping and starting PostGIS once the container has been created as shown above:
```bash
docker container stop postgres-osm
docker container start postgres-osm
```

# Loading PostGIS with data

Internally `make` is used to download OSM data, load it into the database and generate vector tiles from it.
To see the various targets that are supported run
```bash
docker run -it --rm joeakeem/tileserver:latest make
```

Precondition for loading data into the PostGIS database is that the database was started with the docker command above.

To load the data for Switzerland only run:
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make load-switzerland
```
Note that the directory ~/osm/ must exist. This is where the data  will be created.

To load data for the whole of Europe run:
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make load-europe
```

Loading contour data into the database:
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make shp2pgsql-contour
```

Note that each time one of the above commands are run, the existing data is deleted from the database and reloaded from scratch.
In order to download "fresh" data the files in ./data/download need to be deleted so `make` will pull the files anew.

# Building the tiles

To build all tiles run
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make all
```

To build e.g. just the vector tiles for europe run
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make europe
```

To build the contour lines, hillshade and slope vector tiles run
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make contour
```

To build the mountbike singletrail vector tiles run
```bash
docker run -it --rm --link postgres-osm:pg  -v ~/osm/:/data joeakeem/tileserver:latest make mtb
```

The output (mbtiles files) is generated to the ~/osm directory (or to the one you mounted to /data with the docker command above).

# Running the tileserver

Run tileserver in a new container
```
$ docker run --name tileserver -itd -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl -c conf/config.json
```

Stopping and starting the tileserver once the container has been created
```
$ docker container stop tileserver
$ docker container start tileserver
```

# Running Maputnik to style the maps

~/Downloads/maputnik --watch --file styles/basic.json

# Building the tiles documentation

```
$ cd docs
$ make html
$ docker build -t joeakeem/tileserver-docs .
$ docker push joeakeem/tileserver-docs
```
# Running nginx to serve the documentation

Run tileserver-docs in a new container
```
$ docker pull joeakeem/tileserver-docs
$ docker run --name tileserver-docs -d -p 9090:80 joeakeem/tileserver-docs
```

Stopping and starting the tileserver-docs once the container has been created
```
$ docker container stop tileserver-docs
$ docker container start tileserver-docs
```

# Running the reverse proxy

Starting the reverse proxy in a new container
```
$ docker run --name trailmap-nginx -d -p 80:80 joeakeem/trailmap-nginx
```

Stopping and starting the reverse proxy once the container has been created
```
$ docker container stop reverse proxy
$ docker container start reverse proxy
```
