\echo
\echo > Creating function populate
\echo

create or replace function populate
(
  target_schema text,
  shadow_schema text    default 'shadow',
  dry_run       boolean default false
)
returns void
as $$
declare
  l_record record;
begin
  for l_record in select sql
                  from   dml_statement(target_schema, shadow_schema)
                  order  by ordinal_position
  loop
    raise notice '%', l_record.sql;
    if not dry_run then
      execute l_record.sql;
    end if;
  end loop;
end
$$ language plpgsql
   set search_path = pgutl
;