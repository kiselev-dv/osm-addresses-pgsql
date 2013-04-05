create or replace function St_SplitByGrid(in_geometry IN geometry, w IN float, tile OUT geometry)
RETURNS SETOF geometry AS $$
	DECLARE	
		bbox geometry;
		p geometry;
		r record;
		r2 record;
	BEGIN
		
		if ST_GeometryType(in_geometry) = 'MULTIPOLYGON' then

			for r in select (St_Dump(in_geometry)).geom as geom loop
				for r2 in select St_SplitByGrid(r.geom :: geometry, w :: float) tile loop
					tile := r2.tile;
					RETURN NEXT;
				end loop;				
			end loop;
							
		else
			
			bbox := ST_Envelope(in_geometry);
			p := St_SnapToGrid(ST_Centroid(bbox), w, 0);

			begin
				if ST_ISValid(in_geometry) and ST_NPoints(in_geometry) > 5 and ST_Contains(bbox, p) and not St_Distance(bbox, p) > 0.00001 then

					for r in select (ST_Dump(ST_Split(in_geometry, ST_SetSRID(ST_MakeLine(ST_MakePoint(ST_X(p), -90), ST_MakePoint(ST_X(p), 90)), 4326)))).geom as geom loop
						for r2 in select St_SplitByGrid(r.geom :: geometry, w :: float) tile loop
							tile := r2.tile;
							RETURN NEXT;
						end loop;
					end loop;				
				else
					tile := in_geometry;
					RETURN NEXT;
				end if;			
			EXCEPTION
				when SQLSTATE 'XX000' then
				tile := in_geometry;
				RETURN NEXT;
			end;
				
		end if;	
	
	END;

$$ LANGUAGE plpgsql IMMUTABLE;
