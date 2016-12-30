\echo
\echo > Creating view unique_key_constraint
\echo

create or replace view unique_key_constraint
(
  unique_constraint_catalog,
  unique_constraint_schema,
  unique_constraint_name,
  table_catalog,
  table_schema,
  table_name
)
as
  select constraint_catalog,
         constraint_schema,
         constraint_name,
         table_catalog,
         table_schema,
         table_name
  from   information_schema.table_constraints
  where  constraint_type in ('PRIMARY KEY', 'UNIQUE')
    and  (table_catalog,
          table_schema) in (select catalog_name,
                                   schema_name
                            from   schemata)
;
