\echo
\echo > Creating table table_delete_order
\echo

create or replace view table_delete_order
(
  ordinal_position,
  table_catalog,
  table_schema,
  table_name,
  is_deletable
)
as
  with v as (
    select row_number() over (order by max(depth),
                                       table_name) as n,
           table_catalog,
           table_schema,
           table_name
      from table_graph_path a
     group by table_catalog,
              table_schema,
              table_name
  )
  select n,
         table_catalog,
         table_schema,
         table_name,
         exists(select 1
                from   deletable_table a
                where  (a.table_name, a.table_schema, a.table_name) =
                       (v.table_name, v.table_schema, v.table_name))
    from v;
;