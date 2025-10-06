-- === Esquema ===
CREATE TABLE IF NOT EXISTS movies (
  id               INT PRIMARY KEY,               -- respetamos el id del CSV
  nombre           TEXT NOT NULL,
  genero           TEXT,
  descripcion      TEXT,
  tiempo           INT,
  restriccion_edad TEXT,
  is_premiere      BOOLEAN
);

CREATE TABLE IF NOT EXISTS showtimes (
  id            INT PRIMARY KEY,                  -- respetamos el id del CSV
  movie_id      INT NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  start_time    TIMESTAMP NOT NULL,
  precio        NUMERIC(10,2) NOT NULL,
  cinema_id_ext TEXT NOT NULL,
  sala_id_ext   TEXT NOT NULL
);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_showtimes_movie  ON showtimes(movie_id);
CREATE INDEX IF NOT EXISTS idx_showtimes_start  ON showtimes(start_time);
CREATE INDEX IF NOT EXISTS idx_showtimes_cinema ON showtimes(cinema_id_ext);
CREATE INDEX IF NOT EXISTS idx_showtimes_sala   ON showtimes(sala_id_ext);

-- === Import ===
-- 1) /data/movies/movies.csv (con encabezado)
--    columnas esperadas (en orden): id,nombre,genero,descripcion,tiempo,restriccion_edad,is_premiere
DO $$
BEGIN
  BEGIN
    COPY movies (id, nombre, genero, descripcion, tiempo, restriccion_edad, is_premiere)
    FROM '/data/movies/movies.csv'
    WITH (FORMAT csv, HEADER true);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Omitiendo import de movies.csv: %', SQLERRM;
  END;
END $$;

-- 2) showtimes/*/part-0.csv (todas las particiones)
--    columnas esperadas (en orden): id,movie_id,start_time,precio,cinema_id_ext,sala_id_ext
DO $$
BEGIN
  BEGIN
    COPY showtimes (id, movie_id, start_time, precio, cinema_id_ext, sala_id_ext)
    FROM PROGRAM 'bash -lc ''for f in /data/movies/showtimes/*/part-0.csv; do [ -s "$f" ] && tail -n +2 "$f"; done'''
    WITH (FORMAT csv);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Omitiendo import de showtimes: %', SQLERRM;
  END;
END $$;

-- === Ajuste de secuencias (por si luego usas SERIAL/GENERATED) ===
DO $$
DECLARE mmax INT; smax INT;
BEGIN
  SELECT COALESCE(MAX(id), 0) INTO mmax FROM movies;
  SELECT COALESCE(MAX(id), 0) INTO smax FROM showtimes;

  -- crea las secuencias si no existen (idempotente) y ajústalas
  PERFORM 1 FROM pg_class WHERE relkind='S' AND relname='movies_id_seq';
  IF NOT FOUND THEN
    CREATE SEQUENCE movies_id_seq OWNED BY movies.id;
  END IF;
  PERFORM 1 FROM pg_class WHERE relkind='S' AND relname='showtimes_id_seq';
  IF NOT FOUND THEN
    CREATE SEQUENCE showtimes_id_seq OWNED BY showtimes.id;
  END IF;

  SELECT setval('movies_id_seq',    mmax);
  SELECT setval('showtimes_id_seq', smax);
END $$;
