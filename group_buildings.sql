delete from building_groups;
delete from building_to_group;

create temp table  IF NOT EXISTS b_convex (
	src_id bigint[],
	src_type character[],		
	geometry geometry,
	convex_id serial
);
delete from b_convex;

insert into b_convex SELECT 
	    array_agg(src_id),    
	    array_agg(src_type), 	    
	    (case array_length(array_agg(src_id), 1) > 2 when true then ST_ConvexHull(ST_Collect( centroid )) else null end ) AS geometry 
	FROM buildings 			
	GROUP BY ST_SnapToGrid(centroid, 0.005, 0.005);
	

delete from building_groups where not ST_IsValid(geometry);	

insert into building_groups SELECT convex_id, geometry FROM b_convex where GeometryType(geometry) = 'POLYGON';

insert into building_to_group 
	select (arr_to_table2(c.src_id, c.src_type)).b_id_out, (arr_to_table2(c.src_id, c.src_type)).b_type_out, convex_id from b_convex c
	where GeometryType(c.geometry) = 'POLYGON';
