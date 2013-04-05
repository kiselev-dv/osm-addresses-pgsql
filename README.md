osm-addresses-pgsql
===================

Postgres postgis project to compile address registry on osm data

Requrie
-------------------

Postgresql 9.1 postgis hstore

To manage pgsnapshot osm postgis schema:
- osmconvert
- osmfilter
- osmosis

Concept
-------------------

- Open. Open not only by license (wtfpl). I try to keep project so simple as I can. 
No magic, every result must be traceable to osm raw data. 
Procedures and techniks must be usefull for any other osm/geospatial projects.
- It's not a validator. First try to find so many addresses and translations as possible, 
second range them as correct and maybe incorrect.
- It has to be fast. Main goal — load data and build full planet addresses index in 24 hours or less on regular pc. 
(Testing on i5 laptop 8gb ram with regular hard drive, no ssd, no raid)


Usefull stuff
------------------
- St_SplitByGrid - tile multipolygons accoarding to grid. 
May be used for point location problem solving speedup, and for generating vector tiles.
At now splits geometry into vertical stripes. (TODO: add horizontal split)

- parse_addresses - return addresses of osm object in normal form, and used address scheme.
For example: addr:street=street1 + addr:street2=street2 + addr:housenumber=1/2 will return 2 rows: 
(street1, 1, N1/N2_1) and (street2, 2, N1/N2_2) and so on.

- collect_names - return values, tag names and locale for every *name* tags assigned to object. 
Locale defined by *name*:<locale>* tag name part.
