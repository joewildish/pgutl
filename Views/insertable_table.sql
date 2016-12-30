\echo
\echo > Creating view insertable_table
\echo

create or replace view insertable_table
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
  where  (table_catalog,
          table_schema,
          table_name) in (select table_catalog,
                                 table_schema,
                                 table_name
                          from   information_schema.table_privileges
                          where  privilege_type = 'INSERT')
;
