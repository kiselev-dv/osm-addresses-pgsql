#!/bin/bash

date

echo "clean"
psql -d osm_snapshot -c "delete from group_to_polygons;"
psql -d osm_snapshot -c "delete from point_to_polygons;"
#psql -d osm_snapshot -c "delete from top_level_boundaries;"

date

echo "find groups"
psql -d osm_snapshot -f group_buildings.sql

date
echo "stripe boundaries"
psql -d osm_snapshot -c "
update polygons p
set geometry = ST_Multi(St_SplitByGrid(p.geometry, 0.01))
where ST_NPoints(p.geometry) > 100;"

date
echo "fill hierarchy for groups"
psql -d osm_snapshot -c "
insert into group_to_polygons select bg.id, p.src_id, p.src_type
	from building_groups bg	
	join polygons p on ST_Contains(p.geometry, bg.geometry); 
"

date
echo "fill hierarchy for points"
psql -d osm_snapshot -c "
insert into point_to_polygons select empty.src_id, empty.src_type, b.src_id, b.src_type from (
	select b.src_id as src_id, b.src_type as src_type, b.centroid as centroid from buildings b where not exists (select 1 from building_to_group bg 
		where b.src_id=bg.b_src_id and b.src_type=bg.b_src_type) and not b.tags ? 'addr:city'
	union
	select b2.src_id as src_id, b2.src_type as src_type, b2.centroid as centroid from buildings b2 join building_to_group gr on b2.src_id = gr.b_src_id and b2.src_type = gr.b_src_type
		where not exists (select 1 from group_to_polygons grp where grp.group_id = gr.group_id) and not b2.tags ? 'addr:city'
) empty join polygons b on ST_Contains(b.geometry, empty.centroid); 
"

date
echo "all done"


