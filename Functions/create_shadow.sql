\echo
\echo > Creating function create_shadow
\echo

create or replace function create_shadow
(
  source_schema text,
  shadow_schema text default 'shadow'
)
returns void
as $$
declare
  l_record record;
begin

  if not exists (select true
                   from schemata
                  where schema_name = source_schema)
  then
    raise 'no such schema: "%"', source_schema;
  end if;

  for l_record in select 0 n,
                         'CREATE SCHEMA '|| quote_ident(shadow_schema) as sql
                  union
                  select row_number() over (order by table_name) n, -- starts at 1
                         'CREATE TABLE '|| quote_ident(shadow_schema) ||'.'|| quote_ident(table_name) ||' '||
                         'AS SELECT * FROM '|| quote_ident(table_schema) ||'.'|| quote_ident(table_name) ||' '||
                         'WHERE FALSE' as sql
                  from   base_table
                  where  table_schema = source_schema
                  order by n
  loop
    raise notice '%', l_record.sql;
    execute l_record.sql;
  end loop;
end
$$ language plpgsql
   set search_path = pgutl
;