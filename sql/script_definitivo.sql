-- =============================================================================
-- PIPELINE DE LIMPIEZA Y ESTRUCTURACIÓN DE DATOS (RR.HH.)
-- Objetivo: Normalizar un dataset crudo de empleados en una BD relacional optimizada.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS clean;
USE clean;

-- drop table limpieza;
-- 1. CREACIÓN DE LA TABLA DE RECOLECCIÓN (STAGING TABLE)
-- Se inicializan las columnas como VARCHAR para permitir la ingesta de datos sucios.
CREATE TABLE IF NOT EXISTS limpieza (
  Id_empleado VARCHAR(255),
  Name VARCHAR(255),
  Apellido VARCHAR(255),
  birth_date VARCHAR(255),
  genero VARCHAR(255),
  area VARCHAR(255),
  salary VARCHAR(255),
  star_date VARCHAR(255),
  finish_date VARCHAR(255),
  promotion_date VARCHAR(255),
  type INT
);

-- 2. INGESTA DE DATOS DESDE ARCHIVO CRUDO CSV
LOAD DATA INFILE 'Limpieza.csv'
INTO TABLE limpieza 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 3. ESTANDARIZACIÓN Y REFRACTORIZACIÓN DE NOMBRES DE COLUMNAS
ALTER TABLE limpieza CHANGE COLUMN Id_empleado id_emp VARCHAR(255) NULL;
ALTER TABLE limpieza CHANGE COLUMN Name name VARCHAR(255) NULL;
ALTER TABLE limpieza CHANGE COLUMN Apellido surname VARCHAR(255) NULL;
ALTER TABLE limpieza CHANGE COLUMN genero gender VARCHAR(255) NULL;
ALTER TABLE limpieza CHANGE COLUMN star_date start_date VARCHAR(255) NULL;

-- 4. CONTROL DE CALIDAD: ELIMINACIÓN DE DUPLICADOS (DATA QUALITY)
-- Clonamos la estructura para crear una tabla temporal sin registros duplicados.
CREATE TABLE temp_limpieza AS 
SELECT DISTINCT * FROM limpieza;

-- Reemplazamos de forma segura la tabla original con la data desduplicada.
DROP TABLE limpieza;
ALTER TABLE temp_limpieza RENAME TO limpieza;

-- 5. LIMPIEZA DE TEXTO (MANIPULACIÓN DE STRINGS)
-- Eliminación de espacios en blanco espurios en los extremos de los campos clave.
UPDATE limpieza SET name = TRIM(name);
UPDATE limpieza SET surname = TRIM(surname);
UPDATE limpieza SET gender = TRIM(gender);
UPDATE limpieza SET area = TRIM(area);

-- 6. NORMALIZACIÓN DE VALORES CATEGÓRICOS
-- Traducción y estandarización a nomenclatura corporativa global.
UPDATE limpieza SET gender = 
  CASE 
      WHEN gender = 'hombre' THEN 'male'
      WHEN gender = 'mujer' THEN 'female'
      ELSE 'other'
  END;

-- Conversión del indicador numérico de tipo de jornada a etiquetas descriptivas.
ALTER TABLE limpieza MODIFY COLUMN type VARCHAR(50);
UPDATE limpieza SET type =
  CASE 
      WHEN type = '0' THEN 'hybrid'
      WHEN type = '1' THEN 'remote'
      ELSE 'other'
  END;

-- 7. SANEAMIENTO Y LIMPIEZA DE CAMPOS MONETARIOS
-- Remoción de símbolos de moneda ($) y comas para formatear el salario como valor numérico.
UPDATE limpieza SET salary = TRIM(REPLACE(REPLACE(salary, '$', ''), ',', ''));

-- Alteración del tipo de dato a DECIMAL para conservar precisión financiera.
ALTER TABLE limpieza MODIFY COLUMN salary DECIMAL(15,2) NULL;

-- 8. PARSING Y ESTANDARIZACIÓN DE FECHAS (DATE COERCION)
-- Estandarización de fechas de nacimiento al formato normativo YYYY-MM-DD.
UPDATE limpieza SET birth_date = 
  CASE
      WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
      WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
      ELSE NULL
  END;

ALTER TABLE limpieza MODIFY COLUMN birth_date DATE;

-- Estandarización de fechas de contratación (start_date).
UPDATE limpieza SET start_date =
  CASE
      WHEN start_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m/%d/%Y'), '%Y-%m-%d')
      WHEN start_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m-%d-%Y'), '%Y-%m-%d')
      ELSE NULL
  END;

ALTER TABLE limpieza MODIFY COLUMN start_date DATE;

-- 9. TRATAMIENTO DE TIMESTAMPS COMPLEJOS (UTC TIMESTAMPS)
-- Tratamiento especial para finish_date que incluye zona horaria UTC.
ALTER TABLE limpieza ADD COLUMN backup_finish_date TEXT;
UPDATE limpieza SET backup_finish_date = finish_date;

-- Limpieza de strings vacíos a NULL para prevenir fallos en la conversión.
UPDATE limpieza SET finish_date = NULL WHERE finish_date = '';

-- Extracción de la marca temporal y transformación a DATETIME nativo de MySQL.
UPDATE limpieza SET finish_date = STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s UTC')
WHERE finish_date IS NOT NULL;

ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

-- 10. INGENIERÍA DE ATRIBUTOS (DATA ENRICHMENT)
-- Generación analítica de la edad de los empleados en base a la fecha de ejecución.
ALTER TABLE limpieza ADD COLUMN age INT;
UPDATE limpieza SET age = TIMESTAMPDIFF(YEAR, birth_date, CURDATE());

-- Modelado dinámico de correos corporativos utilizando manipulación de strings.
ALTER TABLE limpieza ADD COLUMN email TEXT;
UPDATE limpieza SET email = CONCAT(LOWER(SUBSTRING_INDEX(surname, ' ', 1)), '_', LOWER(SUBSTRING(name, 1, 2)), '.', LOWER(SUBSTRING(type, 1, 1)), '@business.com');

-- =============================================================================
-- AUDITORÍA FINAL Y EXTRACCIÓN DE VISTAS ANALÍTICAS
-- =============================================================================

-- Estructura final validada de la tabla
DESCRIBE limpieza;

-- Vista 1: Cohorte de empleados activos y bajas ordenados por jerarquía geográfica.
SELECT id_emp, name, surname, age, gender, area, salary, email, finish_date 
FROM limpieza
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, surname;

-- Vista 2: Métrica agregada de densidad operativa por departamento.
SELECT area, COUNT(*) as cant_working 
FROM limpieza
GROUP BY area
ORDER BY cant_working DESC;
