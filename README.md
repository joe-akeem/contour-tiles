# Singletrailmap Tileserver

## Getting the code
```bash
git clone https://github.com/joe-akeem/tileserver.git
```

## Building & pushing the docker images
```bash
cd tileserver
./build.sh
```

This will call docker build for all sub projects and push the newly build images to dockerhub.

## Creating the vector tiles
```bash
mkdir ~/osm
docker-compose -f docker-compose-builder.yml up -d
```

This will start the PostGIS database, import OSM data and generate the mbiles files. All data (downloads,
intermediate files and final mbtiles files) will be created in the folder `~/osm`.

See what's going on in one of the containers:
```bash
docker logs -f dockeruser_tilesbuilder_1
```

Once the mbtiles are generated all services can be stopped:
```bash
docker-compose -f docker-compose-builder.yml down
```

## Starting the tileserver
The tileserver relies on the mbtiles files tp be present in the folder `~/osm`. If they have been created as described
above the tiles server can be started as follows: 

```bash
docker-compose -f docker-compose-server.yml -d up
```

This will:
* start the tiles server serving vector tiles from the mbtiles files in ~/osm
* start [Maputnik](https://maputnik.github.io/) (lets you modify the tile server's style sheet on the fly)
* start nginx with the tiles documentation.
* start a reverse proxy that listens on port 80 and proxies the above services on the following URLs:
    * tileserver.singletrail-map.eu
    * maputnik.singletrail-map.eu
    * docs.singletrail-map.eu

In order to test this on a local machine add the following entries to your /etc/hosts file:
```
127.0.0.1      singletrail-map.eu
127.0.0.1      docs.singletrail-map.eu
127.0.0.1      tileserver.singletrail-map.eu
127.0.0.1      maputnik.singletrail-map.eu
```   

## Adding user credentials

The `docs` and `maputnik` services are password protected. The user credentials are saved in the file `tiles-roxy/.htpasswd`.

To create a new credentials file with a new user run

```bash
htpasswd -c .htpasswd user1
```

To add more users to an existing credentials file run

```bash
htpasswd -c .htpasswd user1
```