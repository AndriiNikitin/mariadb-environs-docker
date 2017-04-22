#!/bin/bash
# $1 - worker id to be created
# $2 - branch / native / tar
# $3 - base docker image for dockerfile
# $4 - source directory location in docker image, default /m7
# $5 - build directory location in docker image, default $4

set -e

. common.sh

wwid=${1:0:2}
wid=${wwid:1:2}
branch=$2
image=$3
src=${4-/m7}
bld=${5-$4}

workdir=$(find . -maxdepth 1 -type d -name "$wwid*" | head -1)

if [[ ! -z $workdir ]]; then
  [[ "$(ls -A $workdir)" ]] && ((>&2 echo "Directory $workdir is not empty") ; exit 1)

  [[ $workdir =~ ($wwid-)([^@]*)(\@)(.*)$ ]] || ((>&2 echo "Couldn't parse format of  $workdir, expected $wwid-branch@image") ; exit 1)

  branch=${BASH_REMATCH[2]}
  image=${BASH_REMATCH[4]}
  src=${2-/m7}
  bld=${3-$src}

  workdir=$(pwd)/$wwid-$branch@$image
else
  workdir=$(pwd)/$wwid-$branch@$image
  mkdir $workdir
fi

image=${image//\~/\:}


# [[ -z $image ]] || ((>&2 echo "Docker base image is empty, cannot continue") ; exit 1)
# [[ -z $branch ]] || ((>&2 echo "Source branch is empty, cannot continue") ; exit 1)

# echo $src
# echo $bld

for filename in _plugin/docker/m-{branch,all}@image/* ; do

  # had to put MSYS2_ARG_CONV_EXCL to avoid messy path expansion in MINGW, hope it will work properly on any OS
  MSYS2_ARG_CONV_EXCL="*" m4 -D__workdir=$workdir -D__wwid=$wwid -D__srcdir=$src -D__blddir=$bld -D__branch=$branch -D__image=$image -D__pref=${ERN_CONTAINER_PREFIX} \
       $filename > $workdir/$(basename $filename)
done

# on windows chmod may show an error
detect_windows || for filename in _plugin/docker/m-{branch,all}@image/*.sh ; do
    chmod +x $workdir/$(basename $filename)
done

mkdir $workdir/var

cp -rL _template/install_m-branch_dep.sh $workdir/var
cp common.sh $workdir/var

