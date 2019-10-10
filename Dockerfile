#FROM ubuntu:bionic
#FROM osgeo/gdal:alpine-normal-latest
FROM osgeo/gdal:ubuntu-full-latest

MAINTAINER joeakeem "j.lengacher@gmx.net"

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update -y && apt-get install -y nginx postgis make curl unzip git cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev \
    libbz2-dev libpq-dev libproj-dev lua5.2 liblua5.2-dev \
    build-essential libsqlite3-dev zlib1g-dev


# osm2psql
WORKDIR /tmp
RUN git clone https://github.com/openstreetmap/osm2pgsql.git
WORKDIR /tmp/osm2pgsql
RUN git checkout tags/1.0.0

RUN mkdir build
WORKDIR /tmp/osm2pgsql/build
RUN cmake ..
RUN make
RUN make install

# tippecanoe
WORKDIR /tmp
RUN git clone https://github.com/mapbox/tippecanoe.git
WORKDIR /tmp/tippecanoe
RUN make -j
RUN make install

# cleanup
RUN rm -rf /tmp/osm2pgsql /tmp/tippecanoe

# tileserver documentation
RUN apt-get install -y python-pip python-sphinx
RUN pip install sphinx_bootstrap_theme sphinx_rtd_theme sphinx_fontawesome

COPY /conf /conf
COPY Makefile /tileserver/Makefile
COPY sql /sql

WORKDIR /tileserver

ENTRYPOINT ["/usr/bin/make"]
CMD ["all"]