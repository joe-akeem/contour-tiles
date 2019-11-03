# Singletrailmap Tileserver

## Getting the code
```bash
git clone https://github.com/joe-akeem/tileserver.git
```

## Building & pushing the docker images
```bash
cd tileserver
docker-compose -f docker-compose-server.yml build
docker-compose -f docker-compose-server.yml push
docker-compose -f docker-compose-builder.yml build
docker-compose -f docker-compose-builder.yml push
```

This will call docker build for all sub projects and push the newly built images to dockerhub.

## Creating the vector tiles
```bash
mkdir ~/osm
docker-compose -f docker-compose-builder.yml up -d
```

This will start the PostGIS database, import OSM data and generate the mbiles files. All data (downloads,
intermediate files and final mbtiles files) will be created in the folder `~/osm`.
The PostGIS database can be reached at localhost:5432

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
docker-compose -f docker-compose-server.yml up -d
```

This will:
* start the tiles server serving vector tiles from the mbtiles files in ~/osm at http://localhost:8080
* start [Maputnik](https://maputnik.github.io/) at http://localhost:9000 
    (lets you modify the tile server's style sheet on the fly)
* start nginx with the tiles documentation at http://localhost:9090 
