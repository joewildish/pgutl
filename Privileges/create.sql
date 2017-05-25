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

\echo
\echo > Grant execute on function create_shadow to public
\echo

grant execute on function create_shadow(text, text) to public
;

\echo
\echo > Grant execute on function drop_shadow to public
\echo

grant execute on function drop_shadow(text) to public
;

\echo
\echo > Grant execute on function populate to public
\echo

grant execute on function populate(text, text, boolean) to public
;