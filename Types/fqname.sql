\echo
\echo > Creating type fqname
\echo

create type fqname as
(
  table_catalog text,
  table_scheme  text,
  table_name    text
)
;
