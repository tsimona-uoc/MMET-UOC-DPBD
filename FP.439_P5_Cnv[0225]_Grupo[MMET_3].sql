-- PLANTILLA DE ENTREGA DE LA PARTE PRÁCTICA DE LAS ACTIVIDADES
-- --------------------------------------------------------------
-- Actividad: AAn(P5)
--
-- Grupo: Cnv0225_Grupo03: [MMET]
-- 
-- Integrantes: 
-- 1. Maria Ricart Martínez
-- 2. Evarishtu Dongua Kuzin
-- 3. Temis Simon Antonio
-- 4. Marius Ciurana Rodríguez
--
-- Database: [fp_204_23]
-- --------------------------------------------------------------
-- 5.1 Crear manualmente (CREATE TABLE) una tabla denominada shows_semanales. Agregar los siguientes campos:
  año: smallint
  mes: char(5)
  semana: smallint
  catname: varchar(10)
  eventname: varchar(200)
  localidad: varchar(15)
  starttime timestamp

  CREATE TABLE shows_semanales (
    año smallint,
    mes char(5),
    semana smallint,
    catname varchar(10),
    eventname varchar(200),
    localidad varchar(15),
    starttime timestamp
  );
    
CREATE TABLE shows_semanales (
año smallint,
mes char(5),
semana smallint,
catname varchar(10),
eventname varchar(200),
localidad varchar(15),
starttime timestamp
);

-- 5.2 Crear un procedimiento almacenado denominado shows_semana_proxima que realice lo siguiente:
  Vaciar la tabla shows_semanales.
  Llenar la tabla con los shows planificados para la semana siguiente a la semana en curso. Llenar los campos con la siguiente información
  año: Los cuatro dígitos del año (2008).
  mes: Nombre del mes (abreviado), ejemplo: JUN.
  semana: Número de semana, ejemplo: 26.
  catname: Nombre descriptivo abreviado de un tipo de eventos en un grupo, ejemplo: Opera.
  eventname: Nombre del evento, ejemplo: Hamlet.
  localidad: Nombre del recinto, ejemplo: Cleveland Browns Stadium, concatenado con el nombre de la ciudad, ejemplo: Cleveland.
  starttime Fecha y hora de inicio del evento, ejemplo: 2008-10-10 19:30:00.

DELIMITER //
CREATE PROCEDURE shows_semana_proxima ()
BEGIN

	DECLARE done INT DEFAULT FALSE;
    DECLARE año smallint;
	DECLARE mes char(5);
	DECLARE semana smallint;
	DECLARE catname varchar(10);
	DECLARE eventname varchar(200);
	DECLARE localidad varchar(15);
	DECLARE starttime timestamp;
    
    declare cur cursor for select * from (
		select 
			YEAR(e.starttime) as año, 
			DATE_FORMAT(e.starttime, "%b")  as mes,
			WEEK(e.starttime) as semana,
			c.catname as catname,
			e.eventname as eventname,
			CONCAT(v.venuename, ', ', v.venuecity) as localidad,
			e.starttime as starttime
			from
		event e
		inner join category c on e.catid = c.catid
		inner join venue v on v.venueid = e.venueid
		where
		WEEK(CURDATE()) + 1 = (WEEK(e.starttime))
	) tabla_shows_proxima_semana;
    
	-- Declarar handler para cuando no haya más filas
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	DELETE FROM shows_semanales;

	OPEN cur;
    read_loop: LOOP
        FETCH cur INTO año, mes, semana, catname, eventname, localidad, starttime;
        IF done THEN
            LEAVE read_loop;
        END IF;
       
        INSERT INTO shows_semanales VALUES (año, mes, semana, catname, eventname, localidad, starttime);
    END LOOP;
    CLOSE cur;
END;

call shows_semana_proxima();

-- 5.3 Crear un evento que ejecute cada día sábado a las 8 de la mañana el procedimiento shows_semana_proxima y que permita exportar la tabla shows_semanales generada por el procedimiento anterior a un archivo de texto.
  
DELIMITER //
CREATE EVENT evento_exportacion_diaria
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 08:00:00')
DO
BEGIN
CALL shows_semana_proxima();

SELECT * 
INTO OUTFILE '/tmp/datos_diarios.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM shows_semanales;
END;


-- 5.4 Crear manualmente una tabla denominada ventas_entradas. Agregar los siguientes campos:
  caldate: date. Fecha de calendario, como 2008-06-24.
  sellerid: integer. Referencia de clave externa a la tabla USERS (el usuario que vendió los tickets).
  sellername: varchar(35) Usar la función NombreResumido para llenar este campo
  email: varchar(100) Dirección de correo electrónico del usuario
  qtysold: integer. La cantidad de entradas vendidas en una fecha.
  pricepaid: decimal(8,2) La suma del precio total por la venta de entradas.
  profit: decimal(8,2) La suma de las ganancias 85% a pagar al vendedor para ese día.

  create table ventas_entradas (
    caldate date, 
    sellerid integer,
    sellername varchar(35),
    email varchar(100),
    qtysold integer,
    pricepaid decimal(8,2),
    profit decimal(8,2)
  );
    
-- 5.5 Crear un procedimiento almacenado denominado profit_sellers que realice lo siguiente:
  Vaciar la tabla ventas_entradas
  Llenar la tabla, para el día y mes que coincida con el día y el mes de la fecha actual (CURRENT_DATE()).
  (Dado que el año es 2008 no se tomará en cuenta en el ejercicio).
  La tabla deberá tener un registro por cada vendedor cuyas ventas de ese día sean superiores a 0.

  DELIMITER //
  CREATE PROCEDURE profit_sellers ()
  BEGIN
	  DECLARE done INT DEFAULT FALSE;
    DECLARE caldate date;
    DECLARE sellerid integer;
    DECLARE sellername varchar(35);
    DECLARE email varchar(100);
    DECLARE qtysold integer;
    DECLARE pricepaid decimal(8,2);
    DECLARE profit decimal(8,2);
    
    DECLARE cur cursor for SELECT * FROM (
      SELECT
        d.caldate as caldate,
              s.sellerid as sellerid,
              NombreResumido(u.firstname, u.lastname) as sellername,
              u.email as email,
              s.qtysold as qtysold,
              s.pricepaid as pricepaid,
              (0.85 * s.pricepaid) as profit
              FROM
      date d
          inner join sales s on d.dateid = s.dateid
          inner join users u on s.sellerid = u.userid
          WHERE 
          MONTH(d.caldate) = MONTH(CURRENT_DATE()) 
      AND DAY(d.caldate) = DAY(CURRENT_DATE())          
      ) tabla_profit_sellers;

    -- Declarar handler para cuando no haya más filas
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
      
    DELETE FROM ventas_entradas;

    OPEN cur;
      read_loop: LOOP
          FETCH cur INTO caldate, sellerid, sellername, email, qtysold, pricepaid, profit;
          IF done THEN
              LEAVE read_loop;
          END IF;
        
          INSERT INTO ventas_entradas VALUES (caldate, sellerid, sellername, email, qtysold, pricepaid, profit);
      END LOOP;
      CLOSE cur;
    END;

  call profit_sellers();

-- 5.6 Crear un evento que ejecute cada día a las 23:59 el procedimiento profit_sellers.

  DELIMITER // 
  CREATE EVENT evento_exportacion_diaria 
  ON SCHEDULE 
  EVERY 1 DAY 
  STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 23:59:00') 
  DO 
  BEGIN 
  CALL profit_sellers();
  END;

-- 5.7 Inventar un procedimiento almacenado que permita optimizar las operaciones del sistema. Justificarlo
