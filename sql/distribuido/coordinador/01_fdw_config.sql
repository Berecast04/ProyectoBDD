CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Antes de ejecutar, sustituye IP_NODO_2 y las contrasenas de ejemplo.
CREATE SERVER IF NOT EXISTS enoe_nodo_1_srv
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'enoe_nodo_1', port '5432');

CREATE SERVER IF NOT EXISTS enoe_nodo_2_srv
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'IP_NODO_2', dbname 'enoe_nodo_2', port '5432');

CREATE USER MAPPING IF NOT EXISTS FOR postgres
SERVER enoe_nodo_1_srv
OPTIONS (user 'postgres', password 'PASSWORD_NODO_1');

CREATE USER MAPPING IF NOT EXISTS FOR postgres
SERVER enoe_nodo_2_srv
OPTIONS (user 'postgres', password 'PASSWORD_NODO_2');
