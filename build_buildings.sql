insert into buildings select src_rel.id as src_id, 'R' as src_type, ST_Centroid(ST_LineMerge(
	(select ST_Union(way.linestring) from relations as rel 
		join relation_members as memb on rel.id = memb.relation_id
		join ways as way on way.id = memb.member_id
	where rel.id=src_rel.id and memb.member_type = 'W')
)) as geometry, src_rel.tags as tags
from relations as src_rel where src_rel.tags -> 'type' = 'multipolygon' and src_rel.tags ? 'building' and src_rel.tags ?| ARRAY['name', 'addr:housenumber', 'addr:housename'];

insert into buildings select id as src_id, 'W' as src_type, ST_Centroid(linestring) as geometry, tags
from ways 
where tags ? 'building' and tags ?| ARRAY['name', 'addr:housenumber', 'addr:housename'] and not EXISTS(
	select member_id from relation_members where relation_id=id and (member_role='outer' or member_role='inner')
);

insert into buildings select id as src_id, 'N' as src_type, geom, tags from nodes where tags ?| ARRAY['addr:housenumber', 'addr:housename']; 
