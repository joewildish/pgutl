# pgutl

Useful views and functions for postgres.

## function: clean

Delete data according to foreign key dependency graph. e.g.:

[local] joe@postgres=# select pgutl.clean(true);
NOTICE:  DELETE FROM "data"."s"
NOTICE:  DELETE FROM "data"."t"
NOTICE:  DELETE FROM "data"."u"


