create or replace function arr_to_table2(b_id_arr IN bigint[], b_type_arr IN character[],
	b_id_out OUT bigint, b_type_out OUT character)
RETURNS SETOF record AS $$

	DECLARE			
		i int;
	BEGIN
		FOR i IN array_lower(b_id_arr, 1) .. array_upper(b_id_arr, 1)
		LOOP
			b_id_out := b_id_arr[i];
			b_type_out := b_type_arr[i];
			RETURN NEXT;
		END LOOP;
	END;

$$ LANGUAGE plpgsql IMMUTABLE;