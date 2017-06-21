#!/bin/bash

version=__version

( cd __workdir
docker build --tag m7farm/__image${version//\~} . )
