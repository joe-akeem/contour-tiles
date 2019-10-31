FROM nginx

RUN apt-get update -y && apt-get install -y cmake python-dev build-essential python-pip python-sphinx
RUN pip install sphinx_bootstrap_theme sphinx_rtd_theme sphinx_fontawesome

COPY ./ /docs/
RUN cd /docs && make html && mkdir -p /usr/share/nginx && cp -R build/html /usr/share/nginx