delete from splitted_convexes;

insert into splitted_convexes select c.convex_id from b_convex c 
where not EXISTS (select 1 from convex_to_polygons cp where cp.convex_id = c.convex_id)
and array_length(c.ids, 1) >= 100 and array_length(c.ids, 1) < 1000;

--create index convex_split_geometry on convex_split using gist(centroid);

delete from convex_split;

insert into convex_split select (arr_to_table2(c.ids, c.types)).* from b_convex c 
where EXISTs (select 1 from splitted_convexes splt where splt.convex_id = c.convex_id);

update convex_split cs set centroid = b.centroid from buildings b where cs.b_src_id = b.src_id and cs.b_src_type = b.src_type;

insert into b_convex SELECT 
	    array_agg(b_src_id),    
	    array_agg(b_src_type), 
	    ST_ConvexHull(ST_Collect( centroid )) AS geom 
	FROM convex_split 	
	GROUP BY ST_SnapToGrid(centroid, 0.002, 0.002);

----------------------------------------------------------------------------------------

insert into splitted_convexes select c.convex_id from b_convex c 
where not EXISTS (select 1 from convex_to_polygons cp where cp.convex_id = c.convex_id)
and array_length(c.ids, 1) >= 1000;

delete from convex_split;

insert into convex_split select (arr_to_table2(c.ids, c.types)).* from b_convex c 
where EXISTs (select 1 from splitted_convexes splt where splt.convex_id = c.convex_id);

update convex_split cs set centroid = b.centroid from buildings b where cs.b_src_id = b.src_id and cs.b_src_type = b.src_type;

insert into b_convex SELECT 
	    array_agg(b_src_id),    
	    array_agg(b_src_type), 
	    ST_ConvexHull(ST_Collect( centroid )) AS geom 
	FROM convex_split 	
	GROUP BY ST_SnapToGrid(centroid, 0.0006, 0.0006);

-----------------------------------------------------------------------------------------	

delete from b_convex where not ST_IsValid(convex);

delete from b_convex bc where exists (select 1 from splitted_convexes sc where sc.convex_id = bc.convex_id);

insert into convex_to_polygons select c.convex_id, p.src_id, p.src_type
	from b_convex c	
	join polygons p on ST_Contains(p.geometry, c.convex) 
where EXISTs (select 1 from splitted_convexes splt where splt.convex_id = c.convex_id) 
and not p.tags @> 'admin_level=>2' and not p.tags @> 'admin_level=>3' and not p.tags @> 'admin_level=>4';
