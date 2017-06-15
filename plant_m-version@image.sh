#!/bin/bash
set -e

. common.sh

wwid=${1:0:2}
wid=${wwid:1:2}
version=$2
image=$3

workdir=$(find . -maxdepth 1 -type d -name "$wwid*" | head -1)

if [[ ! -z $workdir ]]; then
  [[ "$(ls -A $workdir)" ]] && ((>&2 echo "Directory $workdir is not empty") ; exit 1)

  [[ $workdir =~ ($wwid-)([^@]*)(@)(.*)$ ]] || ((>&2 echo "Couldn't parse format of  $workdir, expected $wwid-version@image") ; exit 1)

  [[ -z $version ]] || ${BASH_REMATCH[2]} == $version || ((>&2 echo "Version mismatch - second parameter ($version) doesn't version in folder $workdir") ; exit 1)
  version=${BASH_REMATCH[2]}
  image=${BASH_REMATCH[4]}

  workdir=$(pwd)/$wwid-$version@$image
else
  workdir=$(pwd)/$wwid-$version@$image
  mkdir $workdir
fi

image=${image//\~/\:}

for filename in _plugin/docker/m-{version,all}@image/* ; do

  # had to put MSYS2_ARG_CONV_EXCL to avoid messy path expansion in MINGW, hope it will work properly on any OS
  MSYS2_ARG_CONV_EXCL="*" m4 -D__workdir=$workdir -D__wwid=$wwid -D__srcdir=$src -D__blddir=$bld -D__version=$version -D__image=$image -D__pref=${ERN_CONTAINER_PREFIX} \
       $filename > $workdir/$(basename $filename)
done

detect_windows || for filename in _plugin/docker/m-{version,all}@image/*.sh ; do
  chmod +x $workdir/$(basename $filename)
done

mkdir $workdir/var

cp -rL _template/install_m-version_dep.sh $workdir/var
cp common.sh $workdir/var

