# Singletrailmap Tileserver

#Getting the code
```bash
git clone https://github.com/joe-akeem/tileserver.git
```

#Building & pushing the docker images
```bash
cd tileserver
./build.sh
```

This will call docker build for all sub projects and push the newly build images to dockerhub.

#Creating the vector tiles
```bash
mkdir ~/osm
docker-compose -f docker-compose-builder.yml up
```

This will start the PostGIS database, import OSM data and generate the mbiles files. All data (downloads,
intermediate files and final mbtiles files) will be created in the folder `~/osm`.

Once the mbtiles are generated all services can be stopped:
```bash
docker-compose -f docker-compose-builder.yml down
```

#Starting the tileserver
The tileserver relies on the mbtiles files tp be present in the folder `~/osm`. If they have been created as described
above the tiles server can be started as follows: 

```bash
docker-compose -f docker-compose-server.yml -d up
```

This will:
* start the tiles server at http://localhost:8080
* start [Maputnik](https://maputnik.github.io/) at http://localhost:9000 (lets you modify the tile server's style sheet on the fly)
* start nginx at http://localhost:9090 with the tiles documentation.
   

------------------------------------------
TODO: everything below is outdated and needs to be updated once the reverse proxy has been moved into this project!

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
