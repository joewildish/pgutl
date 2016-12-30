\echo
\echo > Creating view table_graph_path
\echo

create or replace recursive view table_graph_path
(
  table_catalog,
  table_schema,
  table_name,
  depth,
  path,
  cycle
)
as
  select table_catalog,
         table_schema,
         table_name,
         0,
         array[row(table_catalog :: text,
                   table_schema  :: text,
                   table_name    :: text) :: fqname],
         false
  from   unreferenced_table
  union all
  select r_table_catalog,
         r_table_schema,
         r_table_name,
         1 + depth,
         path || row(r_table_catalog :: text,
                     r_table_schema  :: text,
                     r_table_name    :: text) :: fqname,
         row(r_table_catalog :: text,
             r_table_schema  :: text,
             r_table_name    :: text) = any(path)
  from   table_dependency
  join   table_graph_path using (table_catalog,
                                 table_schema,
                                 table_name)
  where  not cycle
    and  (table_catalog,
          table_schema,
          table_name) <> (r_table_catalog,
                          r_table_schema,
                          r_table_name)
;