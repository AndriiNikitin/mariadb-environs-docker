#!/bin/bash

function exec_error_may_occur()
{
  local output=$($@ 2>&1)
  local res=$?
  [[ $res == 0 ]] || [[ $output == "No such"* ]] || (>2 echo $output; exit $res)
}

exec_error_may_occur docker stop -t0 __pref`'`'__wwid
exec_error_may_occur docker rm __pref`'`'__wwid
