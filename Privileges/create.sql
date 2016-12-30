\echo
\echo > Grant usage on schema pgutl to public
\echo

grant usage on schema pgutl to public
;

\echo
\echo > Grant select on all views in pgutl to public
\echo

grant select on all tables in schema pgutl to public
;

\echo
\echo > Grant execute on function clean to public
\echo

grant execute on function clean(boolean) to public
;
