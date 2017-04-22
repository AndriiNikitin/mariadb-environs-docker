#!/bin/bash

set -e
# this will cleanup environs $1 and $2

# assign arguments in reverse order
((i=$#))

[[ "$i" -ge 1 ]] && mid2=${!i} && ((i--))
[[ "$i" -ge 1 ]] && mid1=${!i} && ((i--))

[[ $mid2 =~ [0-9] ]] || { echo "Expected MariaDB environ id as last parameter, got ($mid2)" 1>&2; exit 1; }
[[ $mid1 =~ [0-9] ]] || { echo "Expected MariaDB environ id as first parameter, got ($mid1)" 1>&2; exit 1; }

[ -d m${mid1}* ] || { echo "Cannot find environ m${mid1}" 1>&2; exit 1; }
[ -d m${mid2}* ] || { echo "Cannot find environ m${mid2}" 1>&2; exit 1; }

docker exec -i m$mid1 bash -x _plugin/galera/_testscript/galera_start_new.sh 0

donor_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' m$mid1)

docker exec -i m$mid2 bash -x _plugin/galera/_testscript/galera_join.sh $donor_ip $donor_ip 0

set -x
m${mid1}*/sql.sh "create database t1; create table t1.x(a varchar(64)); insert into t1.x select @@hostname;"
sleep 1
m${mid2}*/sql.sh "insert into t1.x select @@hostname; select * from t1.x;"
