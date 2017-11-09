#!/bin/bash
#cho docker exec -i __pref`'`'__wwid bash -c "$*"
set -x
docker exec -d __pref`'`'__wwid bash -c "$*"
