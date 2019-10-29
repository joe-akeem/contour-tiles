FROM klokantech/tileserver-gl:latest

COPY basic.json /styles/
COPY config.json /config/

# download and setup maputnik
RUN mkdir /maputnik && curl -L https://github.com/maputnik/editor/releases/download/v1.5.0/maputnik_linux --output /maputnik/maputnik_linux && chmod a+x /maputnik/maputnik_linux
