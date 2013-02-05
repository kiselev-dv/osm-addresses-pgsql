#!/bin/bash

date

echo "clean"
psql -d osm_snapshot -c "delete from group_to_polygons;"
psql -d osm_snapshot -c "delete from top_level_boundaries;"

date

echo "find groups"
psql -d osm_snapshot -f group_buildings.sql

date
echo "stipe 2-4 level boundaries"
psql -d osm_snapshot -c "
insert into top_level_boundaries select p.src_id, p.src_type, ST_Multi(St_SplitByGrid(p.geometry, 0.01)) from polygons p 
where p.tags @> 'admin_level=>2' or p.tags @> 'admin_level=>3' or p.tags @> 'admin_level=>4';"

date
echo "fill hierarchy for convexes levels 2-4"
psql -d osm_snapshot -c "
insert into group_to_polygons select bg.id, p.src_id, p.src_type
	from building_groups bg	
	join top_level_boundaries p on ST_Contains(p.geometry, bg.geometry);"

date
echo "fill hierarchy for groups"
psql -d osm_snapshot -c "
insert into group_to_polygons select bg.id, p.src_id, p.src_type
	from building_groups bg	
	join polygons p on ST_Contains(p.geometry, bg.geometry) 
where not p.tags @> 'admin_level=>2' and not p.tags @> 'admin_level=>3' and not p.tags @> 'admin_level=>4';"

echo "all done"


