#!/bin/bash

date
echo "start import $1"
echo "convert to ru-all.o5m"
#osmconvert "$1" -o=ru-all.o5m
echo "done"

date
echo "filter data"
#osmfilter ru-all.o5m --keep="boundary= place= addr:housenumber= addr:interpolation= type=associatedStreet" -o=ru-addresses.o5m
echo "done"

date
echo "convert filtered data to pbf"
#osmconvert ru-addresses.o5m -o=ru-addresses.pbf
#osmconvert world.o5m -o=ru-addresses.pbf
echo "done"

date
echo "clean snapshot"
osmosis --truncate-pgsql database=osm_snapshot user=dkiselev password=123
echo "done"

date
echo "import into db"
osmosis --read-pbf ru-addresses.pbf --write-pgsql nodeLocationStoreType=TempFile database=osm_snapshot user=dkiselev password=123
echo "done"

date
echo "delete temp files"
#rm ru-all.o5m ru-addresses.o5m ru-addresses.pbf

date
echo "all done."
