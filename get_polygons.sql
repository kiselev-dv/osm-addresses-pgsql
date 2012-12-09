select b.src_id, b.src_type, ST_AsText(b.centroid), %# b.tags, %# poly.tags
	from buildings b 
	join polygons poly on ST_Covers(poly.geometry, b.centroid)
