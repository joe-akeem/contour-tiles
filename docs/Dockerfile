FROM nginx

RUN apt-get update -y && apt-get install -y cmake python-dev build-essential

RUN apt-get install -y python-pip python-sphinx
RUN pip install sphinx_bootstrap_theme sphinx_rtd_theme sphinx_fontawesome

COPY ./ /docs/
RUN cd /docs && make html && cp -R build/html /usr/share/nginx/html

RUN ls /usr/share/nginx/html