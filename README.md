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

- It's not a validator. First try to find so many addresses and translations as possible, second range them as correct and maybe incorrect.
- It has to be fast. Main goal — load data and build full planet addresses index in 24 hours or less on regular pc. (Testing on i5 laptop 8gb ram with regular hard drive, no ssd, no raid)
