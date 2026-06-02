-- Respaldos
pg_dump -U postgres -F c -b -v -f backups/centralizado/enoe_centralizada.backup enoe_centralizada
pg_dump -U postgres -F c -b -v -f backups/nodo_1/enoe_nodo_1.backup enoe_nodo_1
pg_dump -U postgres -F c -b -v -f backups/nodo_2/enoe_nodo_2.backup enoe_nodo_2

-- Restauracion
pg_restore -U postgres -d enoe_centralizada -v backups/centralizado/enoe_centralizada.backup
pg_restore -U postgres -d enoe_nodo_1 -v backups/nodo_1/enoe_nodo_1.backup
pg_restore -U postgres -d enoe_nodo_2 -v backups/nodo_2/enoe_nodo_2.backup
