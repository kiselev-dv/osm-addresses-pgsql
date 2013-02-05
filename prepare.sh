#!/bin/bash

date
echo "cleanup tables"
psql -d osm_snapshot -c "delete from polygons;"
psql -d osm_snapshot -c "delete from buildings;"
psql -d osm_snapshot -c "delete from building_addresses;"
echo "done"

date
echo "create multipolygons"
psql -d osm_snapshot -f build_area.sql
echo "done"

date
echo "find building centroids"
psql -d osm_snapshot -f build_buildings.sql
echo "done"

date
echo "apply address scemas"
psql -d osm_snapshot -f carlsrue.sql
psql -d osm_snapshot -f addr_buildings.sql
echo "done"

date
echo "collect names"
psql -d osm_snapshot -c "delete from obj_names;"
psql -d osm_snapshot -f collect_names.sql
psql -d osm_snapshot -c "insert into obj_names select (collect_names(node.tags)).*, node.id, 'N'::character from nodes as node;"
psql -d osm_snapshot -c "insert into obj_names select (collect_names(way.tags)).*, way.id, 'W'::character from ways as way;"
psql -d osm_snapshot -c "insert into obj_names select (collect_names(rel.tags)).*, rel.id, 'R'::character from relations as rel;"
echo "done"

date
echo "extract lang codes from name tags"
psql -d osm_snapshot -c "update obj_names set tag_lang = find_locale(name_tag);"
echo "done"

date
echo "all done."
