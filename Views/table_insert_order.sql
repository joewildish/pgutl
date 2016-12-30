\echo
\echo > Creating table table_insert_order
\echo

create or replace view table_insert_order
(
  ordinal_position,
  table_catalog,
  table_schema,
  table_name,
  is_insertable
)
as
  with v as (
    select row_number() over (order by max(depth) desc,
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
                from   insertable_table a
                where  (a.table_name, a.table_schema, a.table_name) =
                       (v.table_name, v.table_schema, v.table_name))
    from v;
;