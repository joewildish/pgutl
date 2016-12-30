\echo
\echo > Creating function clean
\echo

create or replace function clean
(
  dry_run boolean default false
)
returns void
as $$
declare
  l_record record;
begin
  for l_record in select is_deletable,
                         'DELETE FROM "'|| table_schema ||'"."'|| table_name ||'"' as sql
                    from table_delete_order
                   order by ordinal_position
  loop
    if l_record.is_deletable then
      raise notice '%', l_record.sql;
      if not dry_run then
        execute l_record.sql;
      end if;
    else
      raise notice 'skipping "%"."%", not deletable', l_record.table_schema, l_record.table_name;
    end if;
  end loop;
end
$$ language plpgsql
   set search_path = pgutl
;