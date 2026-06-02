@echo off
set PGUSER=postgres
pg_dump -U %PGUSER% -F c -b -v -f backups\centralizado\enoe_centralizada.backup enoe_centralizada
pg_dump -U %PGUSER% -F c -b -v -f backups\nodo_1\enoe_nodo_1.backup enoe_nodo_1
pg_dump -U %PGUSER% -F c -b -v -f backups\nodo_2\enoe_nodo_2.backup enoe_nodo_2
