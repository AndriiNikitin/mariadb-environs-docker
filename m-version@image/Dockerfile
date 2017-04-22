FROM __image

WORKDIR /farm/_template
COPY var/install_m-version_dep.sh /farm/_template/
WORKDIR /farm

COPY var/common.sh /farm/

WORKDIR /farm
RUN bash -e /farm/_template/install_m-version_dep.sh
WORKDIR /farm/m0-__version
WORKDIR /farm

