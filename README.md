# Singletrailmap Tileserver

# Building the tiles

```
$ make all
```

To build e.g. just the europe tiles:

```
$ make europe
```

The output is generated to the data/mbtiles directory.

# Running the tileserver

docker run --rm -itd -v $(pwd):/data -p 8080:80 klokantech/tileserver-gl -c conf/config.json

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

```
$ docker pull joeakeem/tileserver-docs
$ docker run -d -p 9090:80 joeakeem/tileserver-docs
```
