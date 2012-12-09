CREATE OR REPLACE FUNCTION empty(TEXT)
RETURNS bool AS
        $$ SELECT $1 ~ '^[[:space:]]*$'; $$
        LANGUAGE sql
        IMMUTABLE;
COMMENT ON FUNCTION empty(TEXT)
        IS 'Find empty strings or strings containing only whitespace';


create or replace function collect_names(tags IN hstore, name_value OUT Text, tag OUT Text, lang OUT Text )
RETURNS SETOF record AS $$

	DECLARE			
		tag_row record;
		name_split_row record;
		
	BEGIN
		name_value := Null;
		tag := Null;
		lang := Null;
	
		FOR tag_row IN select * from each(tags) where "key" like '%name%' LOOP
			tag := tag_row.key;
			--lang := find_locale(tag_row.key); --too slow
			
			FOR name_split_row IN select btrim(regexp_split_to_table) from regexp_split_to_table(tag_row.value, E'[\\\\;/\\(\\)]') where not empty(regexp_split_to_table) LOOP

				name_value := name_split_row.btrim;			
				RETURN NEXT;
			
			END LOOP;			
			
		END LOOP;		
	END;

$$ LANGUAGE plpgsql IMMUTABLE;

create or replace function find_locale(input_text Text)
RETURNS Text AS $$

	DECLARE			
		result Text;	
		name_split_row record;	
	BEGIN
		result := Null;

		FOR name_split_row IN 
			select btrim(lower(str)) from regexp_split_to_table(input_text, E'[:]') as str 
				join lang_codes lc on ( 	
					not empty(str) and btrim(lower(str)) = lc.code or (
						substring( btrim(lower(str)) from 1 for 2) = lc.code 
						and (lower(str) like '%-latn' or lower(str) like '%-cyrl' or lower(str) like '%-cyr' or lower(str) like '%-lat' )))
			
		LOOP
			result := name_split_row.btrim;		 
			RETURN result;
			
		END LOOP;
		
		RETURN result;
	END;

$$ LANGUAGE plpgsql IMMUTABLE;