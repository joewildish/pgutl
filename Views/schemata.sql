\echo
\echo > Creating view schemata
\echo

create or replace view schemata
(
  catalog_name,
  schema_name,
  schema_owner
)
as
  select catalog_name,
         schema_name,
         schema_owner
  from   information_schema.schemata
  where  schema_name not in ('information_schema', 'public', 'pg_catalog')
    and  schema_name !~ '^pg_.*$'
;
