Create or replace function ST_ConcaveHull_Safe(geomA geometry , target_percent float)
RETURNS geometry AS $$
		
	BEGIN
		return ST_ConcaveHull(geomA , target_percent);	
	EXCEPTION
		WHEN SQLSTATE 'XX000' THEN
		return null;
				
	END;


$$ LANGUAGE plpgsql IMMUTABLE;