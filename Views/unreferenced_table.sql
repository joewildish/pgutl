\echo
\echo > Creating view unreferenced_table
\echo

create or replace view unreferenced_table
(
  table_catalog,
  table_schema,
  table_name
)
as
  select table_catalog,
         table_schema,
         table_name
  from   base_table
  except
  select r_table_catalog,
         r_table_schema,
         r_table_name
  from   table_dependency
;