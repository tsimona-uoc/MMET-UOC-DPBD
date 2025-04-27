-- Pregunta 2.15 Crear una nueva tabla usuarios sin ventas que deberá guardar aquellos usuarios que no han vendido ningún ticket
-- con los campos userid, firstname, lastname, phone.

/* Creamos la tabla de usuarios sin ventas*/

DROP TABLE users_without_sells;  

CREATE TABLE users_without_sells (
	userid int,
    firstname varchar(30),
    lastname varchar(30),
    phone char(14)
    );

/* Añadimos a la tabla users_without_sells los usuarios en users cuya id no coincida con sellerid */

INSERT INTO users_without_sells (userid, firstname, lastname, phone)
SELECT users.userid, users.firstname, users.lastname, users.phone
FROM users
LEFT JOIN sales ON users.userid = sales.sellerid
WHERE sales.sellerid IS NULL;

/* Optimización */
-- Se crean los índices para acelerar la operación JOIN
ALTER TABLE sales ADD INDEX idx_sellerid (sellerid);
ALTER TABLE users ADD INDEX idx_userid (userid);

INSERT INTO users_without_sells (userid, firstname, lastname, phone)
SELECT u.userid, u.firstname, u.lastname, u.phone
FROM users u 
LEFT JOIN sales s ON u.userid = s.sellerid
WHERE s.sellerid IS NULL;

-- Se eliminan los índices para no afectare operaciones de escritura.
DROP INDEX idx_sellerid ON sales;
DROP INDEX idx_userid ON users;

-- Pregunta 2.19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT 
CONCAT(YEAR(s.saletime), 'Trimestre', QUARTER(s.saletime)) AS trimestre,  -- CONCAT concatena el año junto con el trimestre en una misma columna. QUARTER divide el "saletime" en cuatro. La columna se mostrará como trimestre.
ROUND(AVG(s.pricepaid), 2) AS precio_promedio_por_trimestre, -- Al utilizar cláusula GROUP BY y QUARTER, la media de "pricepaid" se calcula para cada una de las cuatro partes. La columna se mostrará como precio promedio por trimestre.
(SELECT ROUND(AVG(pricepaid), 2) FROM sales) AS precio_promedio_total -- La subconsulta calculará la media del "pricepaid" total de la tabla "sales". La columna se mostrará como precio promedio total. 
FROM sales s
GROUP BY YEAR(s.saletime), QUARTER(s.saletime); -- Con la cláusula GROUP BY.. QUARTER, se asegura que la medía de pricepaid se haga por cada cuatrimestre.

/*Optimizacion*/
ALTER TABLE sales ADD INDEX idx_saletime (saletime); 
SELECT 
	CONCAT(YEAR(s.saletime), 'Q', QUARTER(s.saletime)) AS trimestre, -- Formato trimestre se reemplaza por Q. 
    ROUND(AVG(s.pricepaid), 2) AS precio_promedio_por_trimestre, 
    ROUND((SELECT AVG(pricepaid) FROM sales), 2) AS precio_promedio_total -- Se calcula primero el promedio y después se hace el redondeo.
FROM 
	sales s
GROUP BY
	YEAR(s.saletime),
    QUARTER(s.saletime)
ORDER BY
	YEAR(s.saletime),
    QUARTER(s.saletime);

DROP INDEX idx_saletime ON sales;
SET SESSION sql_mode=(SELECT CONCAT(@@sql_mode,',ONLY_FULL_GROUP_BY'));
-- Mi conclusión es que la consulta original está bastante bien optimizada. El tiempo de ejecución es mayor en la optimización que en la consulta original...

-- Pregunta 2.23 Crear una vista que muestre las ventas por trimestre y grupo de eventos. Guardar con el nombre Estadisticas
-- Pregunta 2.23 Crear una vista que muestre las ventas por trimestre y grupo de eventos. Guardar con el nombre Estadisticas
CREATE VIEW Estadisticas AS 
SELECT
CONCAT('Q', QUARTER(s.saletime)) as Trimestre, 
e.eventname, 
SUM(qtysold) AS CantidadVendida,
SUM(pricepaid) AS PrecioTotal
FROM sales s
INNER JOIN EVENT e ON s.eventid = e.eventid
GROUP BY 
CONCAT('Q', QUARTER(s.saletime)), 
e.eventname;

/*Optimizacion*/
ALTER TABLE sales ADD INDEX idx_sales_eventid (eventid); -- Indice existente?
ALTER TABLE sales ADD INDEX idx_sales_saletime_qty_price (saletime, qtysold, pricepaid);
ALTER TABLE event ADD INDEX idx_event_eventid (eventid);

CREATE VIEW Estadisticas AS
SELECT
	YEAR (s.saletime) AS Anio, -- Se obtiene solo el año de la fecha.
    QUARTER(s.saletime) AS trimestre_num,
    CONCAT(YEAR(s.saletime), 'Q', QUARTER(s.saletime)) AS Trimestre,
    e.eventid, -- Clave de evento para evitar ambigüedad en caso de que haya eventos con mismos nombres.
    e.eventname,
    SUM(s.qtysold) AS CantidadVendida,
    SUM(s.pricepaid) AS PrecioTotal,
    COUNT(*) AS NumeroVentas
FROM
	sales s
    INNER JOIN event e ON s.eventid = e.eventid
GROUP BY -- Se elimina la funcion CONCAT del group by porque consume muchos recursos.
	YEAR(s.saletime),
    QUARTER(s.saletime),
    e.eventid,
    e.eventname;

SELECT * FROM Estadisticas;
SHOW CREATE VIEW Estadisticas;
DROP VIEW IF EXISTS Estadisticas;    
DROP INDEX idx_sales_eventid ON sales;
DROP INDEX idx_sales_saletime_qty_price ON sales;
DROP INDEX idx_event_eventid ON event;

-- Como conclusión entiendo que la consulta original está ya bastante bien optimizada. Añadiría los índices propuestos y la dejaría como está.

-- Pregunta 3.11 Eliminar de la tabla users a todos aquellos usuarios registrados que no hayan comprado ni vendido 
-- ninguna entrada. Antes de eliminarlos, copiarlos a una tabla denominada backup_users para poder recuperarlos en caso 
-- de ser necesario.
	
/*Creación de tabla*/
CREATE TABLE backup_users_test LIKE users; 

START TRANSACTION;
	
/*Resolución del ejercicio con subconsultas*/
INSERT INTO backup_users_test /*Se insertan en la tabla creada backup_users usuarios que cumplan las dos condiciones*/
SELECT * FROM users
WHERE userid NOT IN (SELECT sellerid FROM sales) AND userid NOT IN (SELECT buyerid FROM sales); /*userid no coincide con sellerid y userid no coincide con buyerid*/

SET FOREIGN_KEY_CHECKS = 0; /*Se desactivan las restricciones de claves foráneas antes de eliminar usuarios, es también recomendable ejecutar START TRANSACTION para poder hacer ROLLBACK.*/
    
DELETE FROM users /*Se eliminan de la tabla users usuarios que cumplan las dos condiciones*/
WHERE userid NOT IN (SELECT sellerid FROM sales) AND userid NOT IN (SELECT buyerid FROM sales); /*userid no coincide con sellerid y userid no coincide con buyerid*/

COMMIT;
    
ROLLBACK;

DROP TABLE backup_users_test;

SELECT *
FROM backup_users_test;

SELECT *
FROM users;

SET FOREIGN_KEY_CHECKS = 1;

/*Resolución del ejercicio con IF*/

CREATE TABLE backup_users LIKE users;

INSERT INTO backup_users /*Se insertan en la tabla creada backup_users usuarios que cumplan las dos condiciones*/
SELECT * 
FROM users
WHERE
	IF (userid NOT IN (SELECT sellerid FROM sales) AND userid NOT IN (SELECT buyerid FROM sales), 1, 0) = 1; /*userid no coincide con sellerid y userid no coincide con buyerid*/

START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM users /*Se eliminan de la tabla users usuarios que cumplan las dos condiciones*/
WHERE 
	IF(userid NOT IN (SELECT sellerid FROM sales) AND userid NOT IN (SELECT buyerid FROM sales), 1, 0) = 1; /*userid no coincide con sellerid y userid no coincide con buyerid*/

COMMIT;

ROLLBACK;

SET FOREIGN_KEY_CHECKS = 1;

SELECT *
FROM users;

SELECT *
FROM backup_users;

-- Pregunta 3.16 Crear una función UDF llamada Pases_cortesía. Se regalará 1 pase de cortesía por cada 10 tickets comprados
-- o vendidos, a los usuarios VIP. Hacer una consulta denominada pases_usuarios para probar la función y guardarla como 
-- una vista. Los campos de la misma deberán ser: userid, username, NombreResumido, número de pases.

DELIMITER \

CREATE FUNCTION Pases_cortesía(ticket_count INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(ticket_count / 10);
END;

CREATE VIEW pases_usuarios 
AS
SELECT 
users.userid, 
users.username, 
NombreResumido(users.firstname, users.lastname) 
AS NombreResumido,
    Pases_cortesía(IFNULL(SUM(sales.qtysold), 0) + IFNULL(SUM(listing.numtickets), 0)) AS num_pases
FROM users
LEFT JOIN sales ON users.userid = sales.buyerid
LEFT JOIN listing ON users.userid = listing.sellerid -- Relaciona las ventas de tickets
WHERE 
users.VIP = 'Sí'
GROUP BY 
users.userid, 
users.username, 
users.firstname, 
users.lastname;

/*Optimizacion*/
ALTER TABLE users ADD INDEX idx_users_vip (VIP, userid);
ALTER TABLE sales ADD INDEX idx_sales_buyerid (buyerid, qtysold);
ALTER TABLE listing ADD INDEX idx_listing_sellerid (sellerid, numtickets);

SHOW FUNCTION STATUS WHERE Db = DATABASE();
SELECT * FROM pases_usuarios;
DROP FUNCTION IF EXISTS Pases_cortesía;
DROP VIEW IF EXISTS pases_usuarios;
DROP INDEX idx_users_vip ON users;
DROP INDEX idx_sales_buyerid ON sales;
DROP INDEX idx_listing_sellerid ON listing;

-- Pregunta 3.20 Hacer una vista llamada cumpleanhos. La consulta de la vista, deberá tener los siguientes campos:
-- userid, username, NombreResumido, VIP, dia, mes, birthdate

CREATE VIEW cumpleanhos AS
(
   SELECT 
      userid, 
      username, 
      NombreResumido(firstname, lastname), 
      VIP, 
      DAY(birthdate) as dia,
      MONTH(birthdate) as mes, 
      DATE(birthdate) as birthdate 
   from 
      users
);

/*Optimizacion*/
ALTER TABLE users ADD INDEX idx_users_birthdate (birthdate);

DROP INDEX idx_users_birthdate AS users;
