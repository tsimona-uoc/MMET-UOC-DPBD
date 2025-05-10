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
-- 1. Crear manualmente (CREATE TABLE) una tabla denominada shows_semanales. 

CREATE TABLE shows_semanales(
año SMALLINT,
mes CHAR(5),
semana SMALLINT,
catname VARCHAR(10),
eventname VARCHAR(200),
localidad VARCHAR(15),
starttime TIMESTAMP 
);
-- 2. Crear un procedimiento almacenado denominado shows_semana_proxima
DELIMITER //
CREATE PROCEDURE shows_semana_proxima()
BEGIN
	DECLARE fecha_referencia DATE DEFAULT '2008-01-10';
	DECLARE done INT DEFAULT FALSE;
	DECLARE año SMALLINT;
	DECLARE mes CHAR(5);
	DECLARE semana SMALLINT;
    DECLARE catname VARCHAR(10);
    DECLARE eventname VARCHAR(200);
    DECLARE localidad VARCHAR(15);
    DECLARE starttime TIMESTAMP;
    
    DECLARE cur CURSOR FOR SELECT * FROM (
		SELECT
			YEAR(e.starttime) AS año,
			DATE_FORMAT(e.starttime, "%b") AS mes,
			WEEK(e.starttime) AS semana,
			c.catname AS catname,
            e.eventname AS eventname,
			v.venuecity AS localidad,
			e.starttime AS starttime
			FROM 
		event e 
		INNER JOIN category c ON c.catid = e.catid
		INNER JOIN venue v ON v.venueid = e.venueid
        WHERE
        WEEK(fecha_referencia) + 1 = (WEEK(e.starttime))
    )AS tabla_shows_semana_proxima;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; 
    
    DELETE FROM shows_semanales;
    
    OPEN cur;
    read_loop: LOOP
    FETCH cur INTO año, mes, semana, catname, eventname, localidad, starttime; 
		IF DONE THEN
			LEAVE read_loop;
		END IF;
        INSERT INTO shows_semanales VALUES (año, mes, semana, catname, eventname, localidad, starttime);
    END LOOP;    
    CLOSE cur;
END // 
DELIMITER ;

SELECT *
FROM shows_semanales;

DROP TABLE shows_semanales;

DROP PROCEDURE shows_semana_proxima;

SELECT * 
FROM event;

SELECT WEEK(starttime) 
FROM event
WHERE WEEK(starttime) = 2;

-- 4. Crear manualmente una tabla denominada ventas_entradas. 
CREATE TABLE ventas_entradas(
caldate DATE,
sellerid INT,
sellername VARCHAR(35),
email VARCHAR(100),
qtysold INT,
pricepaid DECIMAL(8,2),
profit DECIMAL(8,2)
);

-- 5. Crear un procedimiento almacenado denominado profit_sellers.
DELIMITER //
CREATE FUNCTION NombreResumido(nombre VARCHAR(30), apellido VARCHAR(30))
RETURNS VARCHAR(35)
DETERMINISTIC
BEGIN
	RETURN CONCAT(UCASE(LEFT(nombre, 1)), '. ', UCASE(apellido));
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE profit_sellers()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE caldate DATE;
    DECLARE sellerid INT;
    DECLARE sellername VARCHAR(35);
    DECLARE email VARCHAR(100);
    DECLARE qtysold INT;
    DECLARE pricepaid DECIMAL(8,2);
    DECLARE profit DECIMAL(8,2);
    
    DECLARE cur CURSOR FOR SELECT * FROM(
		SELECT 
			d.caldate AS caldate,
            s.sellerid AS sellerid,
            NombreResumido(u.firstname, u.lastname) AS sellername,
            u.email AS email,
            s.qtysold AS qtysold,
            s.pricepaid AS pricepaid,
            (0.85 * s.pricepaid) AS profit
			FROM
            date d 
            INNER JOIN sales s ON s.dateid = d.dateid
            INNER JOIN users u ON u.userid = s.sellerid
            WHERE
            EXTRACT(MONTH FROM d.caldate) = EXTRACT(MONTH FROM CURRENT_DATE()) AND EXTRACT(DAY FROM d.caldate) = EXTRACT(DAY FROM CURRENT_DATE())
    )AS tabla_profit_sellers;
    
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
END//
DELIMITER ;

DROP FUNCTION IF EXISTS NombreResumido;
DROP TABLE IF EXISTS ventas_entradas;
DROP PROCEDURE IF EXISTS profit_sellers;
CALL profit_sellers;

SELECT *
FROM ventas_entradas;

SELECT * 
FROM sales
ORDER BY saletime;
