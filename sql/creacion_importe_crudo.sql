CREATE DATABASE if NOT EXISTS clean;
USE clean;


-- 1. Creación de la tabla Limpieza

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
-- 2. Importe de datos 
LOAD DATA INFILE 'Limpieza.csv'
INTO TABLE Limpieza 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

