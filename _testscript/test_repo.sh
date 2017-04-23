#!/bin/bash

echo $@

set -ex
. common.sh

# this will cleanup environs $1 and $2

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 1 ]] && mid1=${!i} && ((i--))
[[ "$i" -ge 1 ]] && MATRIX_OSIMAGE=${!i} && ((i--))
[[ "$i" -ge 1 ]] && mdbversions=${!i} && ((i--))

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

m$mid1*/exec-i.sh bash -xe <<EOF

  set -e
  . common.sh
  for version in $mdbversions ; do
    if [ \$(detect_yum) == apt ] ; then
#      apt-get install -y mariadb-server-\$versionmajor
      :
      export DEBIAN_FRONTEND=noninteractive
    else
      yum clean all
    fi

    versionmajor=\$version
    [[ \$version =~ .*\\..*\\..* ]] && versionmajor=\${version%.*}
    curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=mariadb-\$version
    if [ \$(detect_yum) == apt ] ; then
      apt-get install -y mariadb-server-\$versionmajor mariadb-client-\$versionmajor mariadb-server-core-\$versionmajor
    else
      yum install -y MariaDB-server MariaDB-client
    fi
    # must sleep a little as on some environments background job may need to upgrade
    mysqld_safe &
    sleep 10
    mysql_upgrade
    mysql --version
    mysqladmin shutdown || :
    sleep 3
    if [ "\$(mysql --version)" != *\$version* ] || [ "\$(mysqld --no-defaults --version)" != *\$version* ] ; then
      >&2 echo 'check failed - actual version mismatch: expected: (\$version) have (\$(mysql --version)) and (\$(mysqld --no-defaults --version))'
      exit 15
    fi
  done
EOF
