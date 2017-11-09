#!/bin/bash

# had to split -v parameter to new line because m4 stops processing if __workdir has hash sign (#)
MSYS2_ARG_CONV_EXCL="*" docker run -dit -v __workdir/../_plugin:/farm/_plugin:ro \
                  -v __workdir/../_matrix:/farm/_matrix:ro \
                  -v __workdir/../_testscript:/farm/_testscript:ro \
                  -v __workdir/../_depot:/farm/_depot \
                  -v __workdir/../_template:/farm/_template:ro --name=__pref`'`'__wwid ${1:-m7farm/__image`'`'system} bash

# additional initialization in case if default image
[ -n "$1" ] || for f in __workdir/../*.sh ; do
  docker cp $f __pref`'`'__wwid:/farm/
done

[ -n "$1" ] || docker exec -i __pref`'`'__wwid bash ./plant.sh m0

