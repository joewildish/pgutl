\echo
\echo > Creating view table_dependency
\echo

create or replace view table_dependency
(
  table_catalog,
  table_schema,
  table_name,
  r_table_catalog,
  r_table_schema,
  r_table_name
)
as
  select distinct
         a.table_catalog as table_catalog,
         a.table_schema  as table_schema,
         a.table_name    as table_name,
         b.table_catalog as r_table_catalog,
         b.table_schema  as r_table_schema,
         b.table_name    as r_table_name
    from information_schema.referential_constraints
    join foreign_key_constraint a
   using (constraint_catalog, constraint_schema, constraint_name)
    join unique_key_constraint b
   using (unique_constraint_catalog, unique_constraint_schema, unique_constraint_name)
;