#!/bin/bash

set -e
. common.sh

# this will cleanup environs $1 and $2

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 1 ]] && mid1=${!i} && ((i--))
[[ "$i" -ge 1 ]] && MATRIX_OSIMAGE=${!i} && ((i--))
[[ "$i" -ge 1 ]] && mdb_versions=${!i} && ((i--))
[[ "$i" -ge 1 ]] && maxscale_versions=${!i} && ((i--))
[[ "$i" -ge 1 ]] && install_xtrabackup=${!i} && ((i--))

[[ "$mid1" =~ ^[0-9]$ ]] || { echo "Expected MariaDB environ id as 3rd parameter, got ($mid1)" 1>&2; exit 1; }
[[ -z $MATRIX_OSIMAGE ]] && { echo "Expected docker image as 2nd parameter, got ($MATRIX_OSIMAGE)" 1>&2; exit 1; }


./replant.sh m$mid1-system@$MATRIX_OSIMAGE

set -x
m${mid1}*/image_create.sh

if ! m"$mid1"*/container_create.sh ; then
# retry - sometimes fails with strange errors
  sleep 5;
  m"$mid"*/container_create.sh
fi

m$mid1*/exec-i.sh _testscript/mariadb_repo_setup.sh "$install_xtrabackup" "$maxscale_versions" "$mdb_versions"
