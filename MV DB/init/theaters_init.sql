-- Esquema
CREATE TABLE IF NOT EXISTS cinemas (
  id        INTEGER PRIMARY KEY,  -- respetamos el id del CSV
  nombre    TEXT NOT NULL,
  ciudad    TEXT,
  distrito  TEXT,
  nro_salas INTEGER
);

CREATE TABLE IF NOT EXISTS salas (
  id         INTEGER PRIMARY KEY, -- respetamos el id del CSV
  cine_id    INTEGER NOT NULL REFERENCES cinemas(id) ON DELETE CASCADE,
  numero     INTEGER NOT NULL,
  capacidad  INTEGER,
  tipo_sala  TEXT,
  UNIQUE(cine_id, numero)
);

-- Import (el contenedor ejecuta: /mnt/theaters/theaters.db ".read /mnt/init/theaters_init.sql")
.mode csv
.headers on

-- columnas esperadas:
-- cinemas.csv: id,nombre,ciudad,distrito,nro_salas
-- salas.csv:   id,cine_id,numero,capacidad,tipo_sala
.import --skip 1 /mnt/theaters_data/cinemas.csv cinemas
.import --skip 1 /mnt/theaters_data/salas.csv   salas

-- Índices
CREATE INDEX IF NOT EXISTS idx_salas_cine ON salas(cine_id);
CREATE INDEX IF NOT EXISTS idx_salas_num  ON salas(numero);
