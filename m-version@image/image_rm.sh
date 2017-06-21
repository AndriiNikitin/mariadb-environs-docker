#!/bin/bash

version=__version

docker rmi m7farm/__image${version//~}
