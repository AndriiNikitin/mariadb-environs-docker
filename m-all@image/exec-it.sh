#!/bin/bash
if [ $# -eq 0 ] ; then
  docker exec -it __pref`'`'__wwid bash
else
  docker exec -it __pref`'`'__wwid bash -c "$*"
fi
