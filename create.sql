\echo
\echo > Creating schema pgutl
\echo

create schema pgutl
;

\echo
\echo > Setting session schema to pgutl
\echo

set session schema 'pgutl'
;

\i Types/create.sql
\i Views/create.sql
\i Functions/create.sql
\i Privileges/create.sql