-- switch addresses by addr scheme
insert into building_addresses select (parse_addresses(b.src_id, b.src_type, b.tags)).* from buildings b;

-- connect associated streets
update building_addresses as addr
set street_way = w.id, assctd_strt_rel = rel.id
	FROM relation_members rmb
	JOIN relations rel on (rmb.relation_id = rel.id and rel.tags @> 'type=>associatedStreet')
	JOIN relation_members rmw on rmw.relation_id = rel.id
	LEFT JOIN ways w on (rmw.member_id = w.id and rmw.member_type = 'W' and rmw.member_role = 'street')
	where rmb.member_role = 'house' and w.tags ? 'name' and rmb.member_id = addr.src_id and rmb.member_type = addr.src_type;
