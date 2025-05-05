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
    starttime DATETIME
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


/*Primero creo una consulta para observar como se verá cada fila y de que tabla debo sacar cada información que pide el procedimiento*/

SELECT 
    YEAR(e.starttime) AS año,
    UPPER(DATE_FORMAT(e.starttime, '%b')) AS mes,
    WEEK(e.starttime, 1) AS semana,
    c.catname,
    e.eventname,
    CONCAT(v.venuename, ', ', v.venuecity) AS localidad,
    e.starttime
FROM event e
JOIN category c ON e.catid = c.catid
JOIN venue v ON e.venueid = v.venueid
LIMIT 10;

/*Una vez observado que funciona, creamos el procedimiento teniendo en cuenta la semana próxima */

DELIMITER //

CREATE PROCEDURE shows_semana_proxima()
BEGIN
    TRUNCATE TABLE shows_semanales;

    INSERT INTO shows_semanales (
        año, mes, semana, catname, eventname, localidad, starttime
    )
    SELECT 
        YEAR(e.starttime) AS año,
        UPPER(DATE_FORMAT(e.starttime, '%b')) AS mes,
        WEEK(e.starttime, 1) AS semana,
        c.catname,
        e.eventname,
        CONCAT(v.venuename, ', ', v.venuecity) AS localidad,
        e.starttime
    FROM event e
    JOIN category c ON e.catid = c.catid
    JOIN venue v ON e.venueid = v.venueid
    WHERE WEEK(e.starttime, 1) = WEEK(CURDATE(), 1) + 1
      AND YEAR(e.starttime) = YEAR(CURDATE());
END //

SELECT 
    YEAR(e.starttime) AS año,
    UPPER(DATE_FORMAT(e.starttime, '%b')) AS mes,
    WEEK(e.starttime, 1) AS semana,
    c.catname,
    e.eventname,
    CONCAT(v.venuename, ', ', v.city) AS localidad,
    e.starttime
FROM event e
JOIN category c ON e.catid = c.catid
JOIN venue v ON e.venueid = v.venueid
ORDER BY e.starttime
LIMIT 20;

DELIMITER ;

-- 5.3 Crear un evento que ejecute cada día sábado a las 8 de la mañana el procedimiento shows_semana_proxima y que permita exportar la tabla shows_semanales generada por el procedimiento anterior a un archivo de texto.
    
-- 5.4 Crear manualmente una tabla denominada ventas_entradas. Agregar los siguientes campos:
  caldate: date. Fecha de calendario, como 2008-06-24.
  sellerid: integer. Referencia de clave externa a la tabla USERS (el usuario que vendió los tickets).
  sellername: varchar(35) Usar la función NombreResumido para llenar este campo
  email: varchar(100) Dirección de correo electrónico del usuario
  qtysold: integer. La cantidad de entradas vendidas en una fecha.
  pricepaid: decimal(8,2) La suma del precio total por la venta de entradas.
  profit: decimal(8,2) La suma de las ganancias 85% a pagar al vendedor para ese día.
    
-- 5.5 Crear un procedimiento almacenado denominado profit_sellers que realice lo siguiente:
  Vaciar la tabla ventas_entradas
  Llenar la tabla, para el día y mes que coincida con el día y el mes de la fecha actual (CURRENT_DATE()).
  (Dado que el año es 2008 no se tomará en cuenta en el ejercicio).
  La tabla deberá tener un registro por cada vendedor cuyas ventas de ese día sean superiores a 0.

-- 5.6 Crear un evento que ejecute cada día a las 23:59 el procedimiento profit_sellers.

-- 5.7 Inventar un procedimiento almacenado que permita optimizar las operaciones del sistema. Justificarlo
