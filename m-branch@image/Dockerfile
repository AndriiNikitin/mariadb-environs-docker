FROM __image

WORKDIR /farm/_template
COPY var/install_m-branch_dep.sh /farm/_template/

WORKDIR /farm
COPY var/common.sh /farm/

RUN bash -e /farm/_template/install_m-branch_dep.sh

WORKDIR /farm/m0-__branch
WORKDIR /farm
