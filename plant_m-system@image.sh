#!/bin/bash
. common.sh
set -e

wwid=${1:0:2}
wid=${wwid:1:2}


workdir=$(find . -maxdepth 1 -type d -name "$wwid-system@*" | head -1)

if [[ ! -z $workdir ]]; then
  [[ "$(ls -A $workdir)" ]] && ((>&2 echo "Directory $workdir is not empty") ; exit 1)

  [[ $workdir =~ ($wwid-system)(@)(.*)$ ]] || ((>&2 echo "Couldn't parse format of  $workdir, expected $wwid-system@image") ; exit 1)

  image=${BASH_REMATCH[3]}

  workdir=$(pwd)/$wwid-system@$image

  image=${image//\~/\:}
else
  { (>&2 echo "Cannot find directory $wwid-system") ; exit 1; }
fi

for filename in _plugin/docker/m-{system,all}@image/* ; do

  # had to put MSYS2_ARG_CONV_EXCL to avoid messy path expansion in MINGW, hope it will work properly on any OS
  MSYS2_ARG_CONV_EXCL="*" m4 -D__workdir=$workdir -D__wwid=$wwid -D__wid=$wid \
       -D__image=$image -D__pref=${ERN_CONTAINER_PREFIX} \
       $filename > $workdir/$(basename $filename)
done


# on windows chmod may show an error
detect_windows || for filename in _plugin/docker/m-{system,all}@image/*.sh ; do
    chmod +x $workdir/$(basename $filename)
done

mkdir $workdir/var

cp -rL _template/install_m-system_dep.sh $workdir/var
cp common.sh $workdir/var

