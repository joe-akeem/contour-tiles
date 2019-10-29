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
RUN apt-get install wget

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get install -y python-gdal gdal-bin

COPY ../conf /conf
COPY Makefile /tileserver/Makefile
COPY sql /sql
COPY ../docs /docs/
RUN cd /docs && make html && cp -R build/html /usr/share/nginx/html

# maputnik
RUN mkdir /maputnik && curl -L https://github.com/maputnik/editor/releases/download/v1.5.0/maputnik_linux --output /maputnik/maputnik_linux && chmod a+x /maputnik/maputnik_linux

WORKDIR /tileserver

ENTRYPOINT ["/usr/bin/make"]
#ENTRYPOINT ["/bin/bash", "-c"]
CMD ["all"]