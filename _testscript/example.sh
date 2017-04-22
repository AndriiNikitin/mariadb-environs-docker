#!/bin/bash

. common.sh

[ -x plant.sh ] || { echo "Test suites must be executed from root folder of Environ framework" 1>&2; exit 1; }

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 1 ]] && mid=${!i} && ((i--))
[[ "$i" -ge 1 ]] && MATRIX_OSIMAGE=${!i} && ((i--))

image=${MATRIX_OSIMAGE:-ubuntu~12.04}

set -e
[[ $mid =~ [0-9] ]] || { echo "Expected MariaDB environ id as last parameter, got ($mid)" 1>&2; exit 1; }

# let's retry few times as `find` may show an error if unrelated folders are deleted in parallel
retry 5 find . -maxdepth 2 -type f -path "./m$mid*/container_cleanup.sh" -exec bash {} \;

# let's retry with timeout, because sometimes I get 'resource is busy' from overloaded disk
retry 5 find . -maxdepth 1 -type d -name "m$mid"\* -exec rm -rf {} +

mkdir m"$mid"-10.1@"$image"
./plant.sh m"$mid"

bash -x m"$mid"*/image_create.sh

m"$mid"*/container_create.sh

docker exec -i m$mid bash -x _testscript/example.sh
