FROM osgeo/gdal:ubuntu-full-3.5.2
MAINTAINER joeakeem "info@singletrail-map.eu"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean

RUN apt-get update -y && apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntugis/ppa

RUN apt-get update -y && apt-get install -y \
        postgis \
        make \
        curl \
        unzip \
        git \
        cmake \
        g++ \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libexpat1-dev zlib1g-dev \
        libbz2-dev \
        libpq-dev \
        libproj-dev \
        lua5.2 \
        liblua5.2-dev \
        build-essential \
        libsqlite3-dev \
        zlib1g-dev \
        wget \
        python3-gdal \
        gdal-bin


# build & install tippecanoe
WORKDIR /tmp
RUN git clone https://github.com/mapbox/tippecanoe.git
WORKDIR /tmp/tippecanoe
RUN make
RUN make install

# cleanup
RUN rm -rf /tmp/tippecanoe

# Add the Makefile & sql scripts
COPY Makefile /contours/Makefile
COPY sql /sql

WORKDIR /contours

ENTRYPOINT ["/usr/bin/make"]
CMD ["all"]