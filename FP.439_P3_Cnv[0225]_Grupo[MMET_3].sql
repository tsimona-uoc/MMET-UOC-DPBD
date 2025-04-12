-- PLANTILLA DE ENTREGA DE LA PARTE PRÁCTICA DE LAS ACTIVIDADES
-- --------------------------------------------------------------
-- Actividad: AAn(P3)
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

-- Funciones condicionales

-- Pregunta 3.9 Mostrar aquellos eventos que se lleven a cabo durante el mes que coincida con el mes en curso.
-- (Ejemplo: si la consulta se hace en marzo, los eventos de marzo de 2008)
-- El listado deberá mostrar los siguientes campos, y estar ordenado por las semanas del mes (week):
-- eventid, eventname, caldate, week, coincideSemana (sí/no).

SELECT e.eventid, e.eventname, d.caldate, d.week,
    CASE 
         WHEN d.week = WEEK(CURRENT_DATE()) THEN 'Si' /*Compara el valor week en la tabla date con la semana actual*/
         ELSE 'No'
    END AS coincideSemana
FROM event e
JOIN date d ON e.dateid = d.dateid /*Se unen ambas tablas a través de la clave dateid*/
WHERE MONTH(d.caldate) = MONTH(CURRENT_DATE()) /*Se muestran solo los eventos cuyo mes (extraído de caldate) coincide con el mes actual.*/
ORDER BY d.week; /* Se ordena la salida por semana*/

-- Pregunta 3.10 Mostrar cuántos usuarios que han comprado entradas para los eventos de la semana 9 son "locales". 
-- Se considera que un usuario es local, si el nombre de la ciudad donde se realiza el evento es igual a la ciudad natal 
-- del usuario, de lo contrario es un visitante.
-- Utilizar la función IF y agrupar.

SELECT CONCAT(e.eventid, e.eventname) AS 'Evento', /*Concatenación de 'eventid' y 'eventname' para crear una columna que identifica los eventos de forma descriptiva.*/
    SUM(IF(v.venuecity = u.city, 1, 0)) AS 'Asistentes Locales', /*Calcula el total de asistentes locales. Si la ciudad del lugar (venue) coincide con la ciudad del usuario, suma 1; de lo contrario, suma 0.*/
    SUM(IF(v.venuecity <> u.city, 1, 0)) AS 'Visitantes' /*Calcula el total de asistentes visitantes. Si la ciudad del lugar es diferente de la ciudad del usuario, suma 1; de lo contrario, suma 0.*/
FROM event e 
JOIN venue v ON e.venueid = v.venueid /*Une la tabla de eventos con la tabla de lugares usando el 'venueid', que relaciona el evento con su lugar*/
JOIN sales s ON e.eventid = s.eventid /*Une la tabla de eventos con la tabla de ventas para saber quién compró entradas para un evento específico*/
JOIN users u ON s.buyerid = u.userid /*Une la tabla de ventas con la tabla de usuarios para acceder a la información de cada comprador (por ejemplo, su ciudad).*/
JOIN date d ON e.dateid = d.dateid /*Une la tabla de eventos con la tabla de fechas para filtrar eventos según la semana específica.*/
WHERE WEEK(d.week) = 9 /*Filtra los eventos que ocurrieron en la semana número 9.*/
GROUP BY e.eventid, e.eventname /*Agrupa los resultados por cada evento, identificándolos mediante su ID y nombre.*/
ORDER BY e.eventid; /*Ordena los resultados por 'eventid' para facilitar la lectura en orden ascendente.*/


-- Pregunta 3.11 Eliminar de la tabla users a todos aquellos usuarios registrados que no hayan comprado ni vendido 
-- ninguna entrada. Antes de eliminarlos, copiarlos a una tabla denominada backup_users para poder recuperarlos en caso 
-- de ser necesario.

-- Como se hace esta consulta con funciones codicionales???

CREATE TABLE users_backup LIKE users;

INSERT INTO users_backup
SELECT *
FROM users
WHERE userid IN (
    SELECT ub.userid
    FROM users_without_buys ub
    INNER JOIN users_without_sells us ON ub.userid = us.userid);

/*Me sale error porque dice que hay usuarios en users_without_sells que estan en listing como fk ya que había usuarios
  cuyo sellerid estaba en la tabla listing pero no en la tabla sales. Se ha creado otra tabla listing_backup_2 para mover
  aquellos usuarios que tiene sellerid en la tabla listing pero no están en la tabla sales*/

create table listing_backup_2 like listing_backup;

insert into listing_backup_2
select *
from listing
where sellerid not in (select sellerid from sales);

delete
from listing
where sellerid not in (select sellerid from sales);

DELETE FROM users
WHERE userid IN (
    SELECT userid FROM (
        SELECT ub.userid
        FROM users_without_buys ub
        INNER JOIN users_without_sells us ON ub.userid = us.userid
    ) AS temp
);
-- Pregunta 3.12 Mostrar una lista de usuarios donde se especifique para cada usuario si éste es un comprador 
-- (sólo ha comprado entradas), un vendedor (sólo ha vendido entradas) o ambos.
-- La salida de la consulta deberá ser la siguiente. Utilizar la función CASE y agrupar. 

SELECT u.userid, u.username, u.firstname, u.lastname,
    CASE 
        WHEN COUNT(DISTINCT s.buyerid) > 0 AND COUNT(DISTINCT l.sellerid) = 0 THEN 'Comprador' /*Evalúa si el usuario ha comprado entradas pero no ha vendido ninguna. Si cumple, asigna el rol "Comprador".*/
        WHEN COUNT(DISTINCT s.buyerid) = 0 AND COUNT(DISTINCT l.sellerid) > 0 THEN 'Vendedor' /*Evalúa si el usuario ha vendido entradas pero no ha comprado ninguna. Si cumple, asigna el rol "Vendedor".*/
        WHEN COUNT(DISTINCT s.buyerid) > 0 AND COUNT(DISTINCT l.sellerid) > 0 THEN 'Ambos' /*Evalúa si el usuario ha comprado y vendido entradas. Si cumple, asigna el rol "Ambos".*/
        ELSE 'Ninguno' /*Asigna el rol "Ninguno" si el usuario no ha comprado ni vendido entradas.*/
    END AS rol /*El resultado del bloque CASE se asigna a la columna `rol`, que indica el rol del usuario.*/
FROM users u 
LEFT JOIN sales s ON u.userid = s.buyerid /*Realiza una unión izquierda con la tabla `sales`, para vincular usuarios que hayan comprado entradas.*/
LEFT JOIN listing l ON u.userid = l.sellerid /*Realiza una unión izquierda con la tabla `listing`, para vincular usuarios que hayan vendido entradas.*/
GROUP BY u.userid, u.username, u.firstname, u.lastname; /*Agrupa los resultados por cada usuario único para aplicar correctamente las funciones agregadas (COUNT).*/


-- Pregunta 3.13 Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
-- Explicar su objetivo en los comentarios de la plantilla .sql

-- Objetivo: La función COALESCE devuelve el primer valor no nulo de una lista de columnas o valores.
-- En este caso, queremos mostrar el número de teléfono de cada usuario. 
-- Si un usuario no tiene teléfono registrado, mostramos un valor alternativo: 'Teléfono no disponible'.

SELECT userid, username,
    COALESCE(phone, 'Teléfono no disponible') AS contact_info
FROM users;

-- Objetivo: IFNULL verifica si un valor es NULL y, si lo es, devuelve un valor alternativo.
-- Aquí mostramos el correo electrónico del usuario o 'Correo no disponible' si está vacío.

SELECT userid, username,
    IFNULL(email, 'Correo no disponible') AS email_info
FROM users;


-- Funciones UDF

-- Pregunta 3.14 Crear una función UDF llamada NombreResumido que reciba como parámetros un nombre y un apellido y retorne
-- un nombre en formato (Inicial de Nombre + "." + Apellido en mayúsculas. Ejemplo: L. LANAU).
-- Probar la función en una consulta contra la tabla de socios y enviando directamente el nombre con tus datos en forma 
-- literal, por ejemplo escribir:
-- SELECT NombreResumido("Rita", "de la Torre") para probar la función, deberá devolver: R. DE LA TORRE.

DELIMITER $$ /*Cambia el delimitador estándar (;) al delimitador $$. Esto es necesario para definir bloques como funciones y procedimientos en MySQL.*/

CREATE FUNCTION NombreResumido(nombre VARCHAR(255), apellido VARCHAR(255)) /*Crea una función llamada NombreResumido*/
RETURNS VARCHAR(255)
DETERMINISTIC /*Especifica que la función es determinística, lo que significa que siempre devolverá el mismo resultado para los mismos parámetros de entrada.*/
BEGIN
    /*Concatenar la inicial del nombre, un punto y el apellido en mayúsculas*/
    RETURN CONCAT(UCASE(LEFT(nombre, 1)), '. ', UCASE(apellido)); /*Obtiene la inicial del 'nombre' (LEFT), la convierte a mayúscula (UCASE), y concatena con un punto y el 'apellido' convertido a mayúsculas.*/
END$$ /*Fin de la definición de la función.*/
DELIMITER ; /*Restaura el delimitador estándar (;).*/

-- Probamos con nuestro nombre

SELECT NombreResumido("Marius", "Ciurana") AS Nombre_Resumido;

-- Probamos con la tabla users

SELECT userid, username, NombreResumido(firstname, lastname) AS Nombre_Resumido 
FROM users; 


-- Pregunta 3.15 Actualizar el campo VIP de la tabla de usuarios a sí a aquellos usuarios que hayan comprado 
-- más de 10 tickets para los eventos o aquellos que hayan vendido más de 25 tickets.

ALTER TABLE users
ADD COLUMN VIP VARCHAR(3) DEFAULT 'No';


-- Actualizar el campo VIP para los usuarios que hayan comprado más de 10 tickets o vendido más de 25 tickets
UPDATE users u
SET u.VIP = 'Sí'
WHERE u.userid IN (
    -- Usuarios que han comprado más de 10 tickets
    SELECT s.buyerid
    FROM sales s
    GROUP BY s.buyerid
    HAVING SUM(s.qtysold) > 10
)
OR u.userid IN (
    -- Usuarios que han vendido más de 25 tickets
    SELECT l.sellerid
	FROM listing l
	GROUP BY l.sellerid
	HAVING SUM(l.numtickets) > 25);

SELECT userid, username, VIP
FROM users
WHERE VIP = 'Sí';

-- Pregunta 3.16 Crear una función UDF llamada Pases_cortesía. Se regalará 1 pase de cortesía por cada 10 tickets comprados
-- o vendidos, a los usuarios VIP. Hacer una consulta denominada pases_usuarios para probar la función y guardarla como 
-- una vista. Los campos de la misma deberán ser: userid, username, NombreResumido, número de pases.

/*Se crea la función*/
DELIMITER $$

CREATE FUNCTION Pases_cortesía(ticket_count INT)
RETURNS INT
DETERMINISTIC
BEGIN
    -- Calcula el número de pases de cortesía basado en el total de tickets
    RETURN FLOOR(ticket_count / 10);
END$$

DELIMITER ;

/*Se crea la vista a raíz de la consulta*/
CREATE VIEW pases_usuarios AS
SELECT u.userid, u.username, NombreResumido(u.firstname, u.lastname) AS NombreResumido,
    Pases_cortesía( /*Se aplica la función creada pase_cortesía*/
        IFNULL(SUM(s.qtysold), 0) + IFNULL(SUM(l.numtickets), 0)
    ) AS num_pases
FROM users u
LEFT JOIN sales s ON u.userid = s.buyerid -- Relaciona las compras de tickets
LEFT JOIN listing l ON u.userid = l.sellerid -- Relaciona las ventas de tickets
WHERE u.VIP = 'Sí' -- Solo aplica a usuarios VIP
GROUP BY u.userid, u.username, u.firstname, u.lastname;

/*Comprobamos la consulta para ver si funciona*/
SELECT * FROM pases_usuarios;

-- Pregunta 3.17 La siguiente instrucción:

/*update mytable
set mycolumn = str_to_date(
concat(
   floor(1 + rand() * (12-1)), '-',
   floor(1 + rand() * (28-1)), '-',
   floor(1 + rand() * (1998-1940) + 1940)),'%m-%d-%Y');*/

-- permite actualizar un campo fecha de una tabla con fechas aleatorias (en este caso el año de nacimiento estaría 
-- en el rango 1998-1940, y los días entre 1 y 28).
-- Sintaxis: select floor(rand()*(end - start) + start);
-- Actualizar el campo birthdate de la tabla users, creado en el P1.

UPDATE users
SET birthdate = STR_TO_DATE(
    CONCAT(
        FLOOR(1 + RAND() * (12 - 1)), '-', -- Mes aleatorio entre 1 y 12
        FLOOR(1 + RAND() * (28 - 1)), '-', -- Día aleatorio entre 1 y 28
        FLOOR(1940 + RAND() * (1998 - 1940))), '%m-%d-%Y'); -- Año aleatorio entre 1940 y 1998



-- Pregunta 3.18 Crear una función UDF llamada Kit_Eventos. Se regalará un kit a aquellos usuarios VIP que cumplan años 
-- durante el mes (que recibirá la función por parámetro). La función devolverá "Kit" o "-". Hacer una consulta pertinente
-- para probar la función.

-- Pregunta 3.19 Inventar una función UDF que permita optimizar las operaciones de la Base de Datos. Justificarla.


-- Variables de @usuario

-- Pregunta 3.20 Hacer una vista llamada cumpleanhos. La consulta de la vista, deberá tener los siguientes campos:
-- userid, username, NombreResumido, VIP, dia, mes, birthdate

-- Pregunta 3.21 Crear dos variables de usuario. Una denominada @esVIP y la otra @monthbirthday.
-- Asignar un valor a la variable @esVIP (true / false).
-- Asignar el valor del mes en curso a la variable @monthbirthday

-- Pregunta 3.22 Hacer una consulta basada en la vista cumpleanhos que utilice las variables de usuario para filtrar los 
-- cumpleañeros del mes en @monthbirthday cuyo valor en el campo VIP coincida con el asignado a la variable @esVIP.
