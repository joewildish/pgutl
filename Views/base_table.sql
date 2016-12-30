\echo
\echo > Creating view base_table
\echo

create or replace view base_table
(
  table_catalog,
  table_schema,
  table_name
)
as
  select table_catalog,
         table_schema,
         table_name
  from   information_schema.tables
  where  table_type = 'BASE TABLE'
    and  (table_catalog,
          table_schema) in (select catalog_name,
                                   schema_name
                            from   schemata)
;
