create or replace function parse_addresses(b_id IN bigint, b_type IN "char", b_tags IN hstore, 
	b_id_out OUT bigint, b_type_out OUT Char, addr_rec_type OUT Text, hn OUT Text, street OUT Text, quarter_tag OUT Text, suburb_tag OUT Text, city_tag OUT Text )
RETURNS SETOF record AS $$

	DECLARE			
		r record;--(Text, Text, bigint, bigint);
		result record;
	BEGIN
		b_id_out := b_id;
		b_type_out := b_type;
	
		-- street2 and housenumber2
		IF b_tags ? 'addr:street2' and b_tags ? 'addr:housenumber2' THEN

			addr_rec_type := 'S2N2_1';
			hn := b_tags -> 'addr:housenumber';
			street := b_tags -> 'addr:street';			
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';

			IF position('/' in hn)  > 0 THEN
				hn := split_part(hn, '/', 1);
			END IF;

			IF position('\\' in hn)  > 0 THEN
				hn := split_part(hn, '\\', 1);
			END IF;
			
			RETURN NEXT;

			addr_rec_type := 'S2N2_2';
			hn := b_tags -> 'addr:housenumber2';
			street := b_tags -> 'addr:street2';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';

			IF position('/' in hn)  > 0 THEN
				hn := split_part(hn, '/', 1);
			END IF;
			
			RETURN NEXT;
		
		-- CZ
		-- streetnumber and conscriptionnumber
		ELSIF b_tags ?| ARRAY['addr:conscriptionnumber', 'addr:streetnumber'] THEN
			
			addr_rec_type := 'SNCN_1';
			hn := b_tags -> 'addr:streetnumber';
			street := b_tags -> 'addr:street';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;

			addr_rec_type := 'SNCN_2';
			hn := b_tags -> 'addr:conscriptionnumber';
			street := Null;
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;
			
	
		-- housenumber=hn1/hn2 helo St. Petersburg
		ELSIF b_tags ? 'addr:street2' THEN

			addr_rec_type := 'N1/N2_1';

			IF position('/' in b_tags -> 'addr:housenumber')  > 0 THEN
				hn := split_part(b_tags -> 'addr:housenumber', '/', 1);
			END IF;

			IF position('\\' in b_tags -> 'addr:housenumber')  > 0 THEN
				hn := split_part(b_tags -> 'addr:housenumber', '\\', 1);
			END IF;
			
			street := b_tags -> 'addr:street';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;
			

			addr_rec_type := 'N1/N2_2';
			IF position('/' in b_tags -> 'addr:housenumber')  > 0 THEN
				hn := split_part(b_tags -> 'addr:housenumber', '/', 2);
			END IF;

			IF position('\\' in b_tags -> 'addr:housenumber')  > 0 THEN
				hn := split_part(b_tags -> 'addr:housenumber', '\\', 2);
			END IF;
			street := b_tags -> 'addr:street2';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;
			

		-- addrN helo to me as cheme author
		ELSIF b_tags ?| ARRAY['addr2:housenumber', 'addr2:housename', 'addr2:street'] THEN

			addr_rec_type := 'ADRN_1';
			hn := b_tags -> 'addr:housenumber';
			street := b_tags -> 'addr:street';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;

			addr_rec_type := 'ADRN_2';
			hn := b_tags -> 'addr2:housenumber';
			street := b_tags -> 'addr2:street';
			quarter_tag := b_tags -> 'addr2:quarter';
			suburb_tag := b_tags -> 'addr2:suburb';
			city_tag := b_tags -> 'addr2:city';
			RETURN NEXT;

			IF b_tags ?| ARRAY['addr3:housenumber', 'addr3:street'] THEN

				addr_rec_type := 'ADRN_3';
				hn := b_tags -> 'addr3:housenumber';
				street := b_tags -> 'addr3:street';
				quarter_tag := b_tags -> 'addr3:quarter';
				suburb_tag := b_tags -> 'addr3:suburb';
				city_tag := b_tags -> 'addr3:city';
				RETURN NEXT;
			
			END IF;

			IF b_tags ?| ARRAY['addr4:housenumber', 'addr4:street'] THEN

				addr_rec_type := 'ADRN_4';
				hn := b_tags -> 'addr4:housenumber';
				street := b_tags -> 'addr4:street';
				quarter_tag := b_tags -> 'addr4:quarter';
				suburb_tag := b_tags -> 'addr4:suburb';
				city_tag := b_tags -> 'addr4:city';
				RETURN NEXT;
			
			END IF;

		--classic carlsrue
		ELSE
			addr_rec_type := 'CR';
			hn := b_tags -> 'addr:housenumber';
			street := b_tags -> 'addr:street';
			quarter_tag := b_tags -> 'addr:quarter';
			suburb_tag := b_tags -> 'addr:suburb';
			city_tag := b_tags -> 'addr:city';
			RETURN NEXT;
				
		END IF;
		
	END;

$$ LANGUAGE plpgsql IMMUTABLE;

/*
create or replace function get_Text(record) returns Text as'

select (b_id_out, b_type_out, addr_rec_type, hn, street, quarter_tag, suburb_tag, city_tag) from parse_addresses($1,$2, $3)

'
language 'sql' strict immutable;
*/

/*
create or replace function join_street(street IN Text, b_id IN bigint, b_centroid IN geometry, useAsscStreet IN boolean, searchStreetByName IN boolean,
	lang OUT Text, street_name_lang OUT Text, street_id OUT bigint, assc_street_rel_id OUT bigint)
--create or replace function join_street(street IN Text, b_id IN bigint, b_centroid IN geometry, useAsscStreet IN boolean, searchStreetByName IN boolean)
RETURNS SETOF record AS $$

	DECLARE			
		finded_by_rel boolean;
		finded_by_name boolean;
		tags_a Text[][];
		i int;
		tag Text[];
		r record;
	BEGIN
		finded_by_rel := False;
		finded_by_name := False;
		
		IF street IS NOT NULL THEN
		
			IF useAsscStreet THEN
				-- as I know only one associated street used now
				FOR r IN 
					SELECT w.tags as tags, w.id as w_id, rel.id as r_id FROM relation_members rmb
						JOIN relations rel on (rmb.relation_id = rel.id and rel.tags @> 'type=>associatedStreet')
						JOIN relation_members rmw on rmw.relation_id = rel.id
						JOIN ways w on rmw.member_id = w.id
					WHERE rmb.member_id = b_id limit 1
				LOOP
					finded_by_rel := True;
					tags_a := hstore_to_matrix(r.tags);
					FOR i IN array_lower(tags_a, 1) .. array_upper(tags_a, 1) LOOP
						tag := tags_a[i];
						IF position('name:' in tag[0]) = 0 then
							--TODO: add check for some other names

							lang := substring(tag[0] from '.....$');
							street_name_lang := tag[1]; 
							street_id := r.w_id; 
							assc_street_rel_id := r.rel_id;
							
							RETURN NEXT;
						end if;					
					end loop;				
				END LOOP;
			END IF;
		
			IF searchStreetByName and not finded_by_rel THEN
				FOR r IN				
					SELECT w.tags as tags, w.id as w_id, NULL as r_id FROM ways w									
					WHERE ST_DWithin(b_centroid, w.linestring, 0.0006) and w.tags -> 'name' = street -- and TODO search by names in other languages and standart names
				LOOP
					-- 0.0006 примерно 500 метров
					finded_by_name := True;
					tags_a := hstore_to_matrix(r.tags);				
					FOR i IN array_lower(tags_a, 1) .. array_upper(tags_a, 1) LOOP
						tag := tags_a[i];
						IF position('name:' in tag[0]) = 0 then
						
							--TODO: add check for some other names
							lang := substring(tag[0] from '.....$');
							street_name_lang := tag[1]; 
							street_id := r.w_id; 
							assc_street_rel_id := r.rel_id;
							
							RETURN NEXT;
						end if;					
					end loop;				
				END LOOP;
			END IF;

			IF (NOT finded_by_name AND NOT finded_by_rel) THEN
			
				lang := Null;
				street_name_lang := street; 
				street_id := Null; 
				assc_street_rel_id := Null;
				
				RETURN NEXT;	
			END IF;
		ELSE
		
			lang := Null;
			street_name_lang := street; 
			street_id := Null; 
			assc_street_rel_id := Null;
				
			RETURN NEXT;	
					
		END IF;
				
	END;

$$ LANGUAGE plpgsql;

create or replace function join_additionl_levels(b_tags hstore, street_id bigint, assc_street_rel_id bigint, postfix int, add_postfix_to_all boolean)
RETURNS hstore AS $$

	DECLARE			
		result hstore;		
	BEGIN
		-- there is no way to determine, do search for quarter2, district 2 or not. So don't.

		result := hstore(array[]::varchar[]);
		
		IF postfix > 1 and add_postfix_to_all THEN
		
			IF b_tags ? ('addr:quarter' || postfix) THEN						
				result := result || hstore(('addr:quarter' || postfix), b_tags -> 'addr:quarter');
			END IF;

			IF b_tags ? ('addr:district' || postfix) THEN
				result := result || hstore(('addr:district' || postfix), b_tags -> 'addr:district');				
			END IF;

			IF b_tags ? ('addr:city' || postfix) THEN
				result := result || hstore(('addr:city' || postfix), b_tags -> 'addr:city');				
			END IF;

		ELSE

			IF b_tags ? 'addr:quarter' THEN
				result := result || ('addr:quarter' => (b_tags -> 'addr:quarter'));
			END IF;

			IF b_tags ? 'addr:district' THEN
				result := result || ('addr:district' => (b_tags -> 'addr:district'));
			END IF;

			IF b_tags ? 'addr:city' THEN
				result := result || ('addr:city' => (b_tags -> 'addr:city'));
			END IF;

		END IF;

		IF postfix < 2 THEN

			IF NOT NULL street_id THEN
				result := result || ('addr:street_id' => street_id);
			END IF;

			IF NOT NULL assc_street_rel_id THEN
				result := result || ('addr:assc_street_rel_id' => assc_street_rel_id);
			END IF;
			
		ELSE
		
			IF NOT NULL street_id THEN
				result := result || (('addr:street_id'||postfix) => street_id);
			END IF;

			IF NOT NULL assc_street_rel_id THEN
				result := result || (('addr:assc_street_rel_id'||postfix) => assc_street_rel_id);
			END IF;
			
		END IF;

		RETURN result;
	END;

$$ LANGUAGE plpgsql;*/
