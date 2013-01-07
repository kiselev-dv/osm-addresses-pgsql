#!/bin/bash

date

echo "clean"
psql -d osm_snapshot -c "delete from b_convex;"
psql -d osm_snapshot -c "delete from convex_to_polygons;"
psql -d osm_snapshot -c "delete from building_to_polygons;"
psql -d osm_snapshot -c "delete from top_level_boundaries;"

date

echo "create convexes for building nodes clusters"

psql -d osm_snapshot -c "
	insert into b_convex SELECT 
	    array_agg(src_id),    
	    array_agg(src_type), 
	    ST_ConvexHull(ST_Collect( centroid )) AS geom 
	FROM buildings 	
	GROUP BY ST_SnapToGrid(centroid, 0.005, 0.005);"

echo "delete invalid convexes"
psql -d osm_snapshot -c "delete from b_convex where not ST_IsValid(convex);"

date
echo "fill hierarchy for convexes"
psql -d osm_snapshot -c "
insert into convex_to_polygons select c.convex_id, p.src_id, p.src_type
	from b_convex c	
	join polygons p on ST_Contains(p.geometry, c.convex) 
where not p.tags @> 'admin_level=>2' and not p.tags @> 'admin_level=>3' and not p.tags @> 'admin_level=>4';"

date
echo "stipe 2-4 level boundaries"
psql -d osm_snapshot -c "
insert into top_level_boundaries select p.src_id, p.src_type, ST_Multi(St_SplitByGrid(p.geometry, 0.01)) from polygons p 
where p.tags @> 'admin_level=>2' or p.tags @> 'admin_level=>3' or p.tags @> 'admin_level=>4';"

date
echo "fill hierarchy for convexes levels 2-4"
psql -d osm_snapshot -c "
insert into convex_to_polygons select c.convex_id, p.src_id, p.src_type
	from b_convex c	
	join top_level_boundaries p on ST_Contains(p.geometry, c.convex);"


date
echo "fill buildings to polygons by convex data"
#psql -d osm_snapshot -f arr_to_table2_function.sql

#date
psql -d osm_snapshot -c "
insert into building_to_polygons select (arr_to_table2(c.ids, c.types)).*, p.p_src_id, p.p_src_type from b_convex c
	join convex_to_polygons p on c.convex_id = p.convex_id;"

echo "all done"


