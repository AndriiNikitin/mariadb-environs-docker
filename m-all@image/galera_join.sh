#!/bin/bash

[ ! -z "$1" ] || { echo "Expected name of donor environ as first parameter; got ($1)";  exit 2; }
[ -d ${1}* ] || { echo "Cannot find environ ($1)";  exit 2; }

set -e

if [ -e "__workdir/../$1*/galera_read_cluster_name.sh" ] ; then
  cluster_name=$(__workdir/../$1*/galera_read_cluster_name.sh)
  join_ip=$(__workdir../$1*/galera_read_ip.sh)
else
# we assume it is docker environ instead
  cluster_name=$(__workdir/../$1*/exec-i.sh 'm0*/galera_read_cluster_name.sh')
  join_ip=$(__workdir/../$1*/exec-i.sh 'm0*/galera_read_ip.sh')
fi

__workdir/exec-i.sh 'mkdir -p remote'
__workdir/exec-i.sh "echo 'echo $cluster_name' > remote/galera_read_cluster_name.sh"
__workdir/exec-i.sh "echo 'echo $join_ip' > remote/galera_read_ip.sh"
__workdir/exec-i.sh 'chmod +x remote/galera_*.sh'


shift

__workdir/exec-i.sh "m0*/galera_join.sh remote $@"
