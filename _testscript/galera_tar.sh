#!/bin/bash

set -e
. common.sh

# this will cleanup environs $1 and $2

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 4 ]] && mid2=${!i} && ((i--))
[[ "$i" -ge 3 ]] && mid1=${!i} && ((i--))
# [[ "$i" -ge 1 ]] && MATRIX_OSIMAGE2=${!i} && ((i--))
[[ "$i" -ge 2 ]] && MATRIX_OSIMAGE=${!i} && ((i--))
# [[ "$i" -ge 1 ]] && ver2=${!i} && ((i--))
[[ "$i" -ge 1 ]] && ver1=${!i} && ((i--))

[[ "$mid1" =~ [0-9] ]] || { echo "Expected MariaDB environ id as 3rd parameter, got ($mid1)" 1>&2; exit 1; }
[ -z "$mid2" ] && [ "$mid1" -le 5 ] && mid2=$((5+$mid1))

[[ $mid2 =~ [0-9] ]] || { echo "Expected MariaDB environ id as last parameter, got ($mid2)" 1>&2; exit 1; }

[[ -z $MATRIX_OSIMAGE ]] && { echo "Expected docker image as second parameter, got ($MATRIX_OSIMAGE)" 1>&2; exit 1; }

[[ $ver1 =~ [1-9][0-9]?\.[0-9](\.[0-9][0-9]?)? ]] || { echo "Expected MariaDB version as first parameter, got ($ver1)" 1>&2; exit 1; }

ver2=$ver1

# let's retry few times as `find` may show an error if unrelated folders are deleted in parallel
retry 5 find . -maxdepth 2 -type f -path "./m$mid1*/container_cleanup.sh" -exec bash {} \;
retry 5 find . -maxdepth 2 -type f -path "./m$mid2*/container_cleanup.sh" -exec bash {} \;

rm -rf m$mid1*
rm -rf m$mid2*

mkdir m$mid1-$ver1@$MATRIX_OSIMAGE
mkdir m$mid2-$ver2@$MATRIX_OSIMAGE

./plant.sh m"$mid1"
./plant.sh m"$mid2"

set -x
m${mid1}*/image_create.sh
m${mid2}*/image_create.sh

m${mid1}*/container_create.sh
m${mid2}*/container_create.sh

m${mid1}*/download.sh
m${mid2}*/download.sh

_plugin/docker/_testscript/galera.sh $mid1 $mid2
