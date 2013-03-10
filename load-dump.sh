#!/bin/bash

date
echo "start import $1"
echo "convert to all.o5m"
osmconvert "$1" -o=all.o5m
echo "done"

date
echo "filter data"
osmfilter all.o5m --keep="admin_level= place= addr:housenumber= addr:interpolation= type=associatedStreet" --keep-ways="highway= and name= " -o=addresses.o5m
rm all.o5m
echo "done"

date
echo "filter places and boundaries"
osmfilter addresses.o5m --keep="admin_level= place= " -o=boundaries.o5m

date
echo "filter buildings and streets"
osmfilter addresses.o5m --keep="addr:housenumber= addr:housename= type=associatedStreet" --keep-ways="highway= and name= " -o=buildings.o5m

date
echo "filter addr interpolation"
osmfilter addresses.o5m --keep="addr:interpolation=" -o=interpolation.o5m

rm addresses.o5m

date
echo "simplify"
osmconvert buildings.o5m --all-to-nodes -o=buildings-simple.o5m
echo "done"

rm buildings.o5m

date
echo "merge data"
osmconvert boundaries.o5m buildings-simple.o5m interpolation.o5m -o=addr-data.pbf

rm streets.o5m buildings-simple.o5m interpolation.o5m

date
echo "clean snapshot"
osmosis --truncate-pgsql database=osm_snapshot user=dkiselev password=123
echo "done"

date
echo "import data"
osmosis --read-pbf addr-data.pbf --write-pgsql nodeLocationStoreType=TempFile database=osm_snapshot user=dkiselev password=123
date

rm addr-data.pbf

date
echo "all done."
