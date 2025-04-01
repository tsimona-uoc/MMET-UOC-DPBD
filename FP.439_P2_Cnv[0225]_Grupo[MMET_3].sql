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

SELECT category.catid, category.catname,
    (SELECT SUM(sales.qtysold) /* Sumamos todos los tickets vendidos de la tabla sales */
     FROM sales 
     WHERE sales.eventid IN ( /* Filtramos mediante una subconsulta los tickets vendidos en la tabla sales cuyos valores coinciden
                                 en la tabla eventos mediante catid */
         SELECT event.eventid 
         FROM event 
         WHERE event.catid = category.catid)) AS tickets_vendidos, /* Mostramos el resultado como tickets vendidos */
    (SELECT SUM(listing.numtickets) /* Sumamos el total de tickets disponibles para la venta */
     FROM listing 
     WHERE listing.eventid IN ( /* Filtramos mediante una subconsulta los tickets totales en la tabla listing cuyos valores coinciden
                                 en la tabla eventos mediante catid */
         SELECT event.eventid 
         FROM event 
         WHERE event.catid = category.catid)) 
    -  /* Restamos los tickets vendidos del total de tickets disponibles para obtener el total de tickets no vendidos */
    (SELECT SUM(sales.qtysold) 
     FROM sales 
     WHERE sales.eventid IN (
         SELECT event.eventid 
         FROM event 
         WHERE event.catid = category.catid)) AS tickets_no_vendidos
FROM category;

-- Pregunta 2.19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por 
-- trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total


-- Pregunta 2.20 Muestra el total de tickets de entradas compradas de Shows y Conciertos.
-- Pregunta 2.21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.

-- Resolver con Vistas

-- Pregunta 2.22 Crea una vista con los eventos del mes de la tabla que coincida con el mes actual. Grabar la vista con el nombre Eventos del mes
-- Pregunta 2.23 Crear una vista que muestre las ventas por trimestre y grupo de eventos. Guardar con el nombre Estadisticas

-- Resolver con Consultas de UNION

-- Pregunta 2.24 Crear una consulta de UNION producto de las tablas usuarios sin compras y usuarios sin ventas:
-- Pregunta 2.25 Crear una consulta de UNION que en forma de tabla las columnas mes, año, 'ventas' as concepto, totalventas y a continuación mes, año, 'comisiones' as concepto, totalcomisiones. Guardarla en forma de vista con el nombre operaciones
