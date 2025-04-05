-- PLANTILLA DE ENTREGA DE LA PARTE PRÁCTICA DE LAS ACTIVIDADES
-- --------------------------------------------------------------
-- Actividad: AAn(P2)
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

-- Resolver con Combinaciones Externas

-- Pregunta 2.14 Crear una nueva tabla usuarios sin compras que deberá guardar aquellos usuarios que no han comprado ningún ticket con los campos userid, firstname, lastname, phone.

/* Creamos la tabla de usuarios sin compras*/

CREATE TABLE users_without_buys (
	userid int,
    firstname varchar(30),
    lastname varchar(30),
    phone char(14)
    );

/* Añadimos a la tabla users_without_buys los usuarios en users cuya id no coincida con buyerid */

INSERT INTO users_without_buys (userid, firstname, lastname, phone)
SELECT users.userid, users.firstname, users.lastname, users.phone
FROM users
LEFT JOIN sales ON users.userid = sales.buyerid
WHERE sales.buyerid IS NULL;

-- Pregunta 2.15 Crear una nueva tabla usuarios sin ventas que deberá guardar aquellos usuarios que no han vendido ningún ticket
-- con los campos userid, firstname, lastname, phone.

/* Creamos la tabla de usuarios sin ventas*/

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

-- Pregunta 2.16 Mostrar una lista con todos los usuarios que no se encuentren en la tabla listing con los campos userid, firstname, lastname, phone.

/* Seleccionamos los campos que deseamos mostrar de la tabla users y lo comparamos con la tabla listing mediante LEFT JOIN
   al igual que en los casos anteriores. Filtramos mediante WHERE .... IS NULL aquellos usuarios que no tienen registro en la tabla listing*/

SELECT users.userid, users.firstname, users.lastname, users.phone
FROM users
LEFT JOIN listing ON users.userid = listing.sellerid
WHERE listing.sellerid IS NULL;

-- Pregunta 2.17 Mostrar aquellas fechas en las cuales no ha habido ningún evento. Se deberá mostrar los campos caldate y holiday

SELECT date.caldate, date.holiday
FROM date
LEFT JOIN event ON date.dateid = event.dateid
WHERE event.dateid IS NULL; /* No devuelve ninguna fecha ya que en todas las fechas hubo algun evento */


-- Resolver con Subconsultas

-- Pregunta 2.18 Mostrar la cantidad de tickets vendidos y sin vender para las diferentes categorías de eventos.
SELECT c.catgroup, 
COALESCE (SUM(s.qtysold), 0) AS tickets_vendidos, -- Se hace la suma de la columna "qtysold", con la cláusula GROUP BY, la suma se hará para cada categoría por separado.
COALESCE (SUM(l.numtickets), 0) - COALESCE(SUM(s.qtysold)) AS tickets_sin_vender -- Se hace la suma total de "numtickets" a la cual se le resta la suma total de "qtysold". La columna se muestra como tickets sin vender. Al igual que antes, las sumas se hacen por categorías. 
FROM category c 
LEFT JOIN event e ON e.catid = c.catid -- Se une tabla "event" con tabla "category", la columna común es "catid"
LEFT JOIN listing l ON l.eventid = e.eventid -- Se une tabla "listing" con tabla "event", la columna común es "eventid"
LEFT JOIN sales s ON e.eventid = s.eventid -- Se une tabla "sales" con tabla "event", la columna comun es "eventid".
GROUP BY c.catgroup -- La cláusula agrupa los datos por categorías, se asegura que las sumas se hagan por cada categoría por separado.
ORDER BY tickets_vendidos DESC; -- Los datos se ordenan por el número de tickets vendidos.

-- Pregunta 2.19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total
SELECT 
CONCAT(YEAR(s.saletime), 'Trimestre', QUARTER(s.saletime)) AS trimestre,  -- CONCAT concatena el año junto con el trimestre en una misma columna. QUARTER divide el "saletime" en cuatro. La columna se mostrará como trimestre.
ROUND(AVG(s.pricepaid), 2) AS precio_promedio_por_trimestre, -- Al utilizar cláusula GROUP BY y QUARTER, la media de "pricepaid" se calcula para cada una de las cuatro partes. La columna se mostrará como precio promedio por trimestre.
(SELECT ROUND(AVG(pricepaid), 2) FROM sales) AS precio_promedio_total -- La subconsulta calculará la media del "pricepaid" total de la tabla "sales". La columna se mostrará como precio promedio total. 
FROM sales s
GROUP BY YEAR(s.saletime), QUARTER(s.saletime) -- Con la cláusula GROUP BY.. QUARTER, se asegura que la medía de pricepaid se haga por cada cuatrimestre.

-- Pregunta 2.20 Muestra el total de tickets de entradas compradas de Shows y Conciertos.

SELECT c.catgroup, -- 
COALESCE (SUM(s.qtysold), 0) AS tickets_vendidos -- Se hace la suma de la columna "qtysold". Con la cláusula GROUP BY, se asegura que la suma se haga de cada categoría por separado. La columna se muestra como tickets_vendidos..
FROM category c 
LEFT JOIN event e ON e.catid = c.catid -- Se une la tabla "event" con tabla "category" la columna común es "catid" 
LEFT JOIN sales s ON e.eventid = s.eventid -- Se une la tabla "sales" con tabla "event" la columna común es "eventid"
WHERE c.catgroup IN ('Concerts', 'Shows') -- Se filtran los datos de columna "catgroup" de la tabla "category" por "Concerts y Shows"
GROUP BY c.catgroup -- La clausula asegura que la suma de "qtysold" se haga por para cada grupo por separado.
ORDER BY tickets_vendidos DESC;

-- Pregunta 2.21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.
SELECT e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity,
SUM(s.qtysold) AS total_tickets_vendidos -- Se hace la suma de "qtysold", debido a la cláusula GROUP BY "eventid", se hará la suma de cada evento.
FROM event e
JOIN venue v ON e.venueid = v.venueid -- Se une la tabla "event" con la tabla "venue", la columna común es "venueid"
JOIN sales s ON e.eventid = s.eventid -- Se une la tabla "sales" con la tabla "event", la columna común es "eventid"
GROUP BY e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity -- La cláusula agrupa cada evento almacenado en "eventid"
ORDER BY total_tickets_vendidos DESC -- Se ordenan los resultados por el número de tickets vendidos de menor a mayor.
LIMIT 1; -- Se muestra solo la primera fila, la de mayor número de tickets vendidos.

-- Resolver con Vistas

-- Pregunta 2.22 Crea una vista con los eventos del mes de la tabla que coincida con el mes actual. Grabar la vista con el nombre Eventos del mes
create view EventosDelMes AS select * from event where MONTH(starttime) = MONTH(CURDATE());
-- Se selecciona el mes de cada entrada y se filtra para que ese mes sea igual al mes en el que se lanza la consulta

-- Pregunta 2.23 Crear una vista que muestre las ventas por trimestre y grupo de eventos. Guardar con el nombre Estadisticas
CREATE VIEW Estadisticas as 
select 
CONCAT('Q', QUARTER(s.saletime)) as Trimestre, 
e.eventname, 
SUM(qtysold) as CantidadVendida,
SUM(pricepaid) as PrecioTotal
from sales s
inner join event e on s.eventid = e.eventid
group by 
CONCAT('Q', QUARTER(s.saletime)), 
e.eventname;
-- Se obtiene el trimestre mediante el metodo QUARTER sobre la columna "saletime", se obtiene el nombre del evento y sumatorio de cantidades e importes agrupando por trimestre y evento

-- Resolver con Consultas de UNION

-- Pregunta 2.24 Crear una consulta de UNION producto de las tablas usuarios sin compras y usuarios sin ventas:

SELECT * FROM users_without_buys
UNION
SELECT * FROM users_without_sells;

-- Pregunta 2.25 Crear una consulta de UNION que en forma de tabla las columnas mes, año, 'ventas' as concepto, totalventas y 
-- a continuación mes, año, 'comisiones' as concepto, totalcomisiones. Guardarla en forma de vista con el nombre operaciones

CREATE VIEW Operaciones AS
SELECT 
	MONTH(saletime) AS Mes,
    YEAR(saletime) AS Año,
    'Ventas' AS Concepto,
    SUM(pricepaid) AS TotalVentas
FROM sales
GROUP BY MONTH(saletime), YEAR(saletime)
UNION
SELECT
	MONTH(saletime) AS Mes,
    YEAR(saletime) AS Año,
    'Comisiones' AS Concepto,
    SUM(commission) AS TotalComisiones
FROM sales
GROUP BY MONTH(saletime), YEAR(saletime)
ORDER BY Mes;
