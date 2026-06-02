CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS enoe_nodo_1_srv
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'enoe_nodo_1', port '5432');

CREATE SERVER IF NOT EXISTS enoe_nodo_2_srv
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'enoe_nodo_2', port '5432');

-- Ajusta user/password si no usas postgres.
CREATE USER MAPPING IF NOT EXISTS FOR postgres
SERVER enoe_nodo_1_srv
OPTIONS (user 'postgres', password 'tu_password');

CREATE USER MAPPING IF NOT EXISTS FOR postgres
SERVER enoe_nodo_2_srv
OPTIONS (user 'postgres', password 'tu_password');
