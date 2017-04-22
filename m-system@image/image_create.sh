#!/bin/bash
cd __workdir
echo $(date)
MSYS2_ARG_CONV_EXCL="*" docker build --tag m7farm/__image`'`'system . 
