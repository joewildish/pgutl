\echo
\echo > Creating function dml_statement
\echo

create or replace function dml_statement
(
  target_schema text,
  shadow_schema text default 'shadow' 
)
returns table
(
  ordinal_position bigint,
  operation        varchar(6),
  table_catalog    information_schema.sql_identifier,
  table_schema     information_schema.sql_identifier,
  table_name       information_schema.sql_identifier,
  sql              text
)
as $$
  with
    key_constraint as (
      select table_catalog,
             table_schema,
             table_name,
             first_value(unique_constraint_name) over
               (partition by table_catalog,
                             table_schema,
                             table_name order by unique_constraint_type) as constraint_name
      from   unique_key_constraint
      where  table_schema = target_schema
      and    table_name in (-- shadowed tables
                            select table_name
                            from   base_table
                            where  table_schema = target_schema
                            intersect
                            select table_name
                            from   base_table
                            where  table_schema = shadow_schema)),
    non_constraint_column_usage as (
      select table_catalog,
             table_schema,
             table_name,
             column_name
      from   columns
      except
      select table_catalog,
             table_schema,
             table_name,
             column_name
      from   constraint_column_usage
    ),
    fragment(table_catalog,
             table_schema,
             table_name,
             columns,
             cons_columns,
             other_columns,
             eq_cons_cols,
             ne_other_cols) as (
      select table_catalog,
             table_schema,
             table_name,
             string_agg(distinct c.column_name, ', ' order by c.column_name),
             string_agg(distinct ccu.column_name, ', ' order by ccu.column_name),
             string_agg(distinct nccu.column_name, ', ' order by nccu.column_name),
             '('|| string_agg(distinct 'a.'|| ccu.column_name, ', ') ||') = ('||
                   string_agg(distinct 'b.'|| ccu.column_name, ', ') ||')',
             '('|| string_agg(distinct 'a.'|| nccu.column_name, ', ') ||') IS DISTINCT FROM ('||
                   string_agg(distinct 'b.'|| nccu.column_name, ', ') ||')'
      from   key_constraint join columns c using (table_catalog,
                                                  table_schema,
                                                  table_name)
                            join constraint_column_usage ccu using (table_catalog,
                                                                    table_schema,
                                                                    table_name)
                            left join non_constraint_column_usage nccu using (table_catalog,
                                                                              table_schema,
                                                                              table_name)
      group by table_catalog,
               table_schema,
               table_name),
    dml(operation,
        table_catalog,
        table_schema,
        table_name,
        sql) as (
      select 'INSERT',
             table_catalog,
             table_schema,
             table_name,
             'INSERT INTO '|| quote_ident(target_schema) ||'.'|| table_name ||' ('|| columns ||') '||
             'SELECT '|| columns ||' FROM '|| quote_ident(shadow_schema) ||'.'|| table_name ||' WHERE ('|| cons_columns ||') '||
             'NOT IN (SELECT '|| cons_columns ||' FROM '|| quote_ident(target_schema) ||'.'|| table_name ||')'
      from   fragment
      union
      select 'UPDATE',
             table_catalog,
             table_schema,
             table_name,
             'UPDATE '|| quote_ident(target_schema) ||'.'|| table_name ||' a '||
             'SET ('|| other_columns ||') = (SELECT '|| other_columns ||' FROM '|| quote_ident(shadow_schema) ||'.'|| table_name ||' b '||
                                            'WHERE '|| eq_cons_cols ||') '||
             'WHERE EXISTS (SELECT TRUE '||
                           'FROM '|| quote_ident(shadow_schema) ||'.'|| table_name ||' B '||
                           'WHERE '|| eq_cons_cols ||' AND '||
                                      ne_other_cols ||')'
      from   fragment
      where  other_columns is not null
      union
      select 'DELETE',
             table_catalog,
             table_schema,
             table_name,
             'DELETE FROM '|| quote_ident(target_schema) ||'.'|| table_name ||' WHERE ('|| cons_columns ||') '||
             'NOT IN (SELECT '|| cons_columns ||' FROM '|| quote_ident(shadow_schema) ||'.'|| table_name ||')'
      from   fragment)
  select row_number() over
           (order by case operation when 'INSERT' then (0, -max(depth))
                                    when 'UPDATE' then (1, -max(depth))
                                    when 'DELETE' then (2, max(depth)) end asc,
                     -- to ensure a symmetric order (kindof) partitioned by operation
                     case when operation in ('INSERT', 'UPDATE') then table_name end asc,
                     case when operation = 'DELETE' then table_name end desc),
         operation,
         table_catalog,
         table_schema,
         table_name,
         sql
  from   dml join table_graph_path using (table_catalog,
                                          table_schema,
                                          table_name)
  group by operation,
           table_catalog,
           table_schema,
           table_name,
           sql
$$ language sql
   set search_path = information_schema, pgutl
;
