USE clean;
-- SET sql_safe_updates = 0;

-- DELIMITER //
-- CREATE PROCEDURE limp()
-- BEGIN
--    SELECT * FROM limpieza LIMIT 10;
-- END
-- DELIMITER ;


CALL limp();


-- Alterar nombres y tipo de datos de columnas en la tabla 

ALTER TABLE limpieza CHANGE COLUMN Id_empleado id_emp VARCHAR(20) NULL;
ALTER TABLE limpieza CHANGE COLUMN genero gender VARCHAR(20) NULL;
ALTER TABLE limpieza CHANGE COLUMN Apellido surname VARCHAR(50) NULL;
ALTER TABLE limpieza CHANGE COLUMN Name name VARCHAR(50) NULL;
ALTER TABLE limpieza CHANGE COLUMN star_date start_date VARCHAR(50) NULL;
ALTER TABLE limpieza MODIFY COLUMN type TEXT;
-- Hacer solamente cuando modifiques los valores para que concuerden con el tipo
-- de dato al que queres cambiar la columna
ALTER TABLE limpieza MODIFY COLUMN salary int NULL;
ALTER TABLE limpieza MODIFY COLUMN birth_date DATE;
ALTER TABLE limpieza MODIFY COLUMN start_date DATE;



-- Identificar duplicado de tablas

SELECT id_emp, COUNT(*) as duplicados
FROM limpieza
GROUP BY id_emp
HAVING count(*) > 1;


-- identificar cantidad de duplicados por medio de una subquery

SELECT count(*) as total_dulicados
from(
    SELECT id_emp, COUNT(*) as cant_rep
    FROM limpieza
    GROUP BY id_emp
    HAVING count(*) > 1
) as subquery;


-- crear una tabla temporal con valores que no se encuentran duplicados

rename table limpieza to conduplicados;

CREATE TEMPORARY TABLE temp_limpieza AS
SELECT DISTINCT * from conduplicados;


-- mostrar cuantos valores tienen las tablas

SELECT COUNT(*) as original FROM conduplicados;
SELECT COUNT(*) as temporal FROM temp_limpieza; 


-- "devolver" los valores a la tabla original o hacer permanente
-- a la tabla que no tiene valores duplicados

CREATE TABLE Limpieza AS SELECT * FROM temp_limpieza;


-- Mostrar propiedades de una tabla (metadatos)
DESCRIBE limpieza;


-- ELiminar espacios vacíos al inicio y final de una cadena de texcto

-- SELECT name 
-- from limpieza
-- where length(name) - length(trim(name)) > 0;

-- Select name, trim(name) as name
-- from limpieza
-- where length(name) - length(trim(name)) > 0;

UPDATE limpieza SET name = trim(name);
UPDATE limpieza SET surname = trim(surname);
UPDATE limpieza SET gender = trim(gender);
UPDATE limpieza SET area = trim(area);


-- identificar si dos palabras contienen mas de un espacio de separación en medio

-- select column_name 
-- from database
-- where column_name regexp '\\s(2,)';


-- borrar espacios de separacion de un valor cuando son más de uno

-- select column_name, trim(regexp_replace(column_name, '\\s+', ' ')) as clean_data
-- from database;

-- UPDATE database SET colmn_name = trim(regexp_replace(column_name, '\\s+', ' '));


-- Cambiar valores de columnas 

update limpieza set gender = 
case 
    when gender = 'hombre' then 'male'
    when gender = 'mujer' then 'female'
    else 'other'
end;

update limpieza set type =
case 
    when type = '0' then 'hibrid'
    when type = '1' then 'remote'
    else 'other'
end;


-- quitar comas, puntos y simbolos en datos de tipo texto y convertirlo a tipo numerico
-- SELECT salary,
-- CAST(trim(replace(replace(salary, '$', ''), ',', '')) as decimal (15,2)) as salary_01
-- from limpieza;

UPDATE limpieza SET salary = 
    CAST(trim(replace(replace(salary, '$', ''), ',', '')) as decimal (15,2));


-- Cambiar formatos de los datos tipo fecha
-- SELECT birth_date,
-- CASE
--      when birth_date like '%/%' then date_format(str_to_date(birth_date, '%m/%d/%y'), '%y-%m-%d')
--      when birth_date like '%-%' then date_format(str_to_date(birth_date, '%m-%d-%y'), '%y-%m-%d')
--      else null
-- END as bith_date_clean
-- FROM limpieza;

update limpieza set birth_date = 
CASE
    when birth_date like '%/%' then date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    when birth_date like '%-%' then date_format(str_to_date(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
    else null
END;

update limpieza set start_date =
CASE
    when start_date like '%/%' then DATE_FORMAT(str_to_date(start_date, '%m/%d/%Y'), '%Y-%m-%d')
    when start_date like '%-%' then date_format(str_to_date(start_date, '%m-%d-%Y'), '%Y-%m-%d')
    else null
END;

alter table limpieza add column backup_finish_date text;
update limpieza set backup_finish_date = finish_date;

update limpieza set finish_date =
STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s UTC')
WHERE finish_date <> '';

alter table limpieza
    add column fecha date,
    add column hora time;

update limpieza
SET fecha = date(finish_date),
    hora = time(finish_date)
where finish_date is not null and finish_date <> '';

update limpieza
set finish_date = NULL
where finish_date = '';

alter table limpieza
modify column finish_date datetime;

-- add a column with the age 
alter table limpieza 
add column age int;

update limpieza set age = timestampdiff(year, birth_date, curdate());

-- crear un correo electronico para los empleados
select concat(substring_index(surname, ' ', 1), '_', 
substring(name, 1, 2), '.', substring(type, 1, 1), '@business.com') as email 
from limpieza;

alter table limpieza 
add column email text;

update limpieza set email = concat(substring_index(surname, ' ', 1), '_', 
substring(name, 1, 2), '.', substring(type, 1, 1), '@business.com');


-- datos para exportar como dos tablas separadas
select id_emp, name, surname, age, gender, area, salary, email, finish_date from limpieza
where finish_date <= curdate() or finish_date = null
order by area, surname;

select area, COUNT(*) as cant_working 
from limpieza
group by area
order by cant_working desc;
