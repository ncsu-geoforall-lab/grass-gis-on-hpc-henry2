#!/usr/bin/tcsh

# shellcheck disable=SC1071

grass79 --tmp-location EPSG:4326 --exec g.region res=0.1 -p
