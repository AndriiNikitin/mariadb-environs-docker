#!/bin/bash

. common.sh

[ -x plant.sh ] || { echo "Test suites must be executed from root folder of Environ framework" 1>&2; exit 1; }

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 1 ]] && mid=${!i} && ((i--))
[[ "$i" -ge 1 ]] && MATRIX_OSIMAGE=${!i} && ((i--))
[[ "$i" -ge 1 ]] && MATRIX_BRANCH=${!i} && ((i--))

image=${MATRIX_OSIMAGE:-ubuntu~12.04}
branch=${MATRIX_BRANCH:-10.1}


set -e
[[ $mid =~ [0-9] ]] || { echo "Expected MariaDB environ id as last parameter, got ($mid)" 1>&2; exit 1; }

# let's retry few times as `find` may show an error if unrelated folders are deleted in parallel
retry 5 find . -maxdepth 2 -type f -path "./m$mid*/container_cleanup.sh" -exec bash {} \;

# let's retry with timeout, because sometimes I get 'resource is busy' from overloaded disk
retry 5 find . -maxdepth 1 -type d -name "m$mid"\* -exec rm -rf {} +

mkdir m"$mid"-${branch}@"$image"
./plant.sh m"$mid"

bash -x m"$mid"*/image_create.sh

if ! m"$mid"*/container_create.sh ; then 
# retry - sometimes fails with strange errors
  sleep 5; 
  m"$mid"*/container_create.sh 
fi

m$mid*/exec-i.sh bash -xe <<'EOF'
# non-root is required for some tests, so make sure sudo is installed
sudo -h &>/dev/null || _template/install_sudo.sh

/usr/sbin/useradd mysql
cd m0* && \
./cmake.sh && \
./build.sh

chown -R mysql build/mysql-test && \
cd build/mysql-test && \
time sudo -u mysql perl mysql-test-run.pl --verbose-restart --force --parallel=4 --retry=3 --mem --max-save-core=0 --max-save-datadir=1
EOF

