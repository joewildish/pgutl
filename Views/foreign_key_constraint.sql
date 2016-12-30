\echo
\echo > Creating view foreign_key_constraint
\echo

create or replace view foreign_key_constraint
(
  constraint_catalog,
  constraint_schema,
  constraint_name,
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
  where  constraint_type = 'FOREIGN KEY'
    and  (table_catalog,
          table_schema) in (select catalog_name,
                                   schema_name
                            from   schemata)
;