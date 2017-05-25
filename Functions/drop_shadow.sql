\echo
\echo > Creating function drop_shadow
\echo

create or replace function drop_shadow
(
  shadow_schema text default 'shadow'
)
returns void
as $$
begin
  execute 'DROP SCHEMA IF EXISTS '|| quote_ident(shadow_schema) ||' CASCADE';
end
$$ language plpgsql
;