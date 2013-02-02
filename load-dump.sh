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

osmfilter addresses.o5m --keep="admin_level= place= " -o=boundaries.o5m
osmfilter addresses.o5m --keep="addr:housenumber= addr:housename= addr:interpolation= type=associatedStreet" -o=buildings.o5m
osmfilter addresses.o5m --keep-ways="highway= and name= " -o=streets.o5m

rm addresses.o5m

date
echo "convert filtered data to pbf"
osmconvert boundaries.o5m -o=boundaries.pbf
date
osmconvert buildings.o5m --all-to-nodes -o=buildings.pbf
date
osmconvert streets.o5m --all-to-nodes -o=streets.pbf
echo "done"

rm addresses.o5m boundaries.o5m buildings.o5m streets.o5m

date
echo "clean snapshot"
osmosis --truncate-pgsql database=osm_snapshot user=dkiselev password=123
echo "done"

date
echo "import boundaries"
osmosis --read-pbf boundaries.pbf --write-pgsql nodeLocationStoreType=TempFile database=osm_snapshot user=dkiselev password=123
date
echo "import buildings"
osmosis --read-pbf buildings.pbf --write-pgsql nodeLocationStoreType=TempFile database=osm_snapshot user=dkiselev password=123
date
echo "import streets"
osmosis --read-pbf streets.pbf --write-pgsql nodeLocationStoreType=TempFile database=osm_snapshot user=dkiselev password=123
echo "done"

date
echo "all done."