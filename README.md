# pgutl

Useful views and functions for postgres.

## function: clean

Delete data according to foreign key dependency graph. e.g.:

    [local] joe@postgres=# select pgutl.clean(true);
    NOTICE:  DELETE FROM "data"."s"
    NOTICE:  DELETE FROM "data"."t"
    NOTICE:  DELETE FROM "data"."u"


## function: create_shadow

Create a schema that shadows the tables from an existing schema, without the integrity constraints. e.g.:

    [local] joe@joe=# select pgutl.create_shadow('foo');
    NOTICE:  CREATE SCHEMA shadow
    NOTICE:  CREATE TABLE shadow.r AS SELECT * FROM foo.r WHERE FALSE
    NOTICE:  CREATE TABLE shadow.s AS SELECT * FROM foo.s WHERE FALSE
    NOTICE:  CREATE TABLE shadow.t AS SELECT * FROM foo.t WHERE FALSE


## function: populate

Populate a schema with data from its shadow. Population is done in manner such that minimal work is done (no superfluous UPDATES, for example), referential integrity is maintained, and can be performed as a normal transaction. e.g.:

    [local] joe@joe=# -- the foo tables are empty
    [local] joe@joe=# select 'r' as t, count(*) from foo.r
                      union
                      select 's', count(*) from foo.s
                      union
                      select 't', count(*) from foo.t order by 1;
    ┌───┬───────┐
    │ t │ count │
    ├───┼───────┤
    │ r │     0 │
    │ s │     0 │
    │ t │     0 │
    └───┴───────┘
    (3 rows)

    [local] joe@joe=# -- populate the shadows
    [local] joe@joe=# insert into shadow.t values (3);
    INSERT 0 1
    [local] joe@joe=# insert into shadow.r values (3);
    INSERT 0 1
    [local] joe@joe=# -- populate the tables in the foo schema from the shadows
    [local] joe@joe=# select populate('foo');
    NOTICE:  INSERT INTO foo.t (n) SELECT n FROM shadow.t WHERE (n) NOT IN (SELECT n FROM foo.t)
    NOTICE:  INSERT INTO foo.r (n) SELECT n FROM shadow.r WHERE (n) NOT IN (SELECT n FROM foo.r)
    NOTICE:  INSERT INTO foo.s (k, m, v) SELECT k, m, v FROM shadow.s WHERE (k, m) NOT IN (SELECT k, m FROM foo.s)
    NOTICE:  UPDATE foo.s a SET (v) = (SELECT v FROM shadow.s b WHERE (a.k, a.m) = (b.k, b.m)) WHERE EXISTS (SELECT
      TRUE FROM shadow.s B WHERE (a.k, a.m) = (b.k, b.m) AND (a.v) IS DISTINCT FROM (b.v))
    NOTICE:  DELETE FROM foo.s WHERE (k, m) NOT IN (SELECT k, m FROM shadow.s)
    NOTICE:  DELETE FROM foo.r WHERE (n) NOT IN (SELECT n FROM shadow.r)
    NOTICE:  DELETE FROM foo.t WHERE (n) NOT IN (SELECT n FROM shadow.t)
    ┌──────────┐
    │ populate │
    ├──────────┤
    │          │
    └──────────┘
    (1 row)

    [local] joe@joe=# -- the foo tables are populated
    [local] joe@joe=# select * from foo.t;
    ┌───┐
    │ n │
    ├───┤
    │ 3 │
    └───┘
    (1 row)

    [local] joe@joe=# select * from foo.r;
    ┌───┐
    │ n │
    ├───┤
    │ 3 │
    └───┘
    (1 row)


## function: drop_shadow

Drops a previously-created shadow schema . e.g:

    [local] joe@joe=# select drop_shadow();
    NOTICE:  drop cascades to 3 other objects
    DETAIL:  drop cascades to table shadow.r
    drop cascades to table shadow.s
    drop cascades to table shadow.t