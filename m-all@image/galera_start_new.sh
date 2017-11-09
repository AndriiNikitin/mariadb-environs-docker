#!/bin/bash

# this will hang, unless -d flag is in exec. 
# but then it shows no eventual errors...
# so start this script with &

__workdir/exec-i.sh "m0*/galera_start_new.sh $*"
