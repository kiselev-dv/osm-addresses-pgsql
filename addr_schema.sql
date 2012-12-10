CREATE TABLE buildings
(
  src_id bigint NOT NULL,
  src_type "char" NOT NULL,
  centroid geometry(Point),
  tags hstore,
  CONSTRAINT buildings_pk PRIMARY KEY (src_id , src_type )
)
WITH (
  OIDS=FALSE
);

CREATE TABLE polygons
(
  src_id bigint NOT NULL,
  src_type "char" NOT NULL,
  geometry geometry(MultiPolygon),
  tags hstore,
  CONSTRAINT polygons_pk PRIMARY KEY (src_id , src_type )
)
WITH (
  OIDS=FALSE
);

CREATE TABLE building_addresses
(
  src_id bigint,
  src_type "char",
  addr_scheme text,
  housenumber text,
  street text,
  quarter text,
  suburb text,
  city text,
  street_way bigint,
  assctd_strt_rel bigint
)
WITH (
  OIDS=FALSE
);

CREATE TABLE obj_names
(
  obj_name text,
  name_tag text,
  tag_lang text,
  src_id bigint,
  src_type character(1)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE lang_codes
(
  code character(2)
)
WITH (
  OIDS=FALSE
);

CREATE INDEX inx_lang_code
  ON lang_codes
  USING btree
  (code COLLATE pg_catalog."default" );
