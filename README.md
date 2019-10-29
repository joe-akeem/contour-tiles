# Singletrailmap Tileserver

#Getting the code
```bash
git clone https://github.com/joe-akeem/tileserver.git
```

#Creating the vector tiles
```bash
mkdir ~/osm
cd tileserver/tiles-builder
docker-compose build
docker-compose up
```

This will the tilesbuilder docker image, start the PostGIS database, import OSM data and generate the mbiles files.

All data (downloads, intermediate files and final mbtiles files) will be created in the folder ~/osm

Once the mbtiles are generated all services can be stopped:
```bash
docker-compose down
```

#Starting the tileserver
```bash
mkdir ~/osm
cd tileserver/tiles-server
docker-compose build
docker-compose up
```


#Building 
```bash
git clone https://github.com/joe-akeem/tileserver.git
cd tileserver
docker-compose build
```

#Running

Run 
```bash
mkdir ~/osm
docker-compose up
``` 

When running for the first time the mbtiles files will be missing and need to be generated before the tileserver
can be started. Generating them can take a looooong time!

Once all services have been started successfully the tileserver can be accessed at http://localhost:8080

The documentation of the mbtiles content can be accessed at http://localhost:9090

The output (mbtiles files) are generated to the ~/osm directory.

The Maputnik style editor can be accessed at http://localhost:8888

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
