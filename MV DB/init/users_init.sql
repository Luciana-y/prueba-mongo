SET NAMES utf8mb4;
SET sql_mode = 'STRICT_ALL_TABLES';

-- Base: MYSQL_DATABASE=bookingdb (según tu compose)
CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36) NOT NULL PRIMARY KEY,  -- viene desde el CSV
  email         VARCHAR(320) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  phone_number  VARCHAR(64),
  first_name    VARCHAR(128) NOT NULL,
  surname       VARCHAR(128) NOT NULL,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
