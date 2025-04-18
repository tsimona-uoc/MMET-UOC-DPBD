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

SELECT 
	CONCAT(e.eventid, ' - ', e.eventname) AS Evento, /*Concateno las columnas para mostrar eventid y eventname juntos en la misma columna a la cual llamaré Evento */
    SUM(IF(u.city = v.venuecity, 1, 0)) AS `Asistentes Locales`, /*Hago la suma de aquellos casos en los cuales el comprador es de la misma ciudad que el evento que se vaya a celebrar */
    SUM(IF(u.city != v.venuecity, 1, 0)) AS `Asistentes Visitantes` /*Hago la suma de aquellos casos en los cuales el comprador es de ciudad diferente que el evento que se vaya a celebrar */
FROM 
	event e 
    JOIN venue v ON e.venueid = v.venueid /*Combino la tabla venue con la tabla event donde venueid es PK en la tabla venue y FK en la tabla event */
    JOIN sales s ON e.eventid = s.eventid /*Combino la tabla sales con la tabla event donde eventid es PK en la tabla event y FK en la tabla sales */
    JOIN users u ON u.userid = s.buyerid /*Combino la tabla users con la tabla sales donde userid es PK en la tabla users y FK en la tabla sales*/
    JOIN date d ON d.dateid = e.dateid /*Combino la tabla date con la tabla event donde dateid es PK en la tabla date y FK en la tabla event*/
WHERE
	d.week = 9 /*Añado la condición de la semana número nueve para solo considerar aquellos eventos celebrados esta semana*/
GROUP BY
	e.eventid, e.eventname /*Agrupo la consulta por eventid y eventname */
ORDER BY e.eventid;

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

-- Pregunta 3.12 Mostrar una lista de usuarios donde se especifique para cada usuario si éste es un comprador 
-- (sólo ha comprado entradas), un vendedor (sólo ha vendido entradas) o ambos.
-- La salida de la consulta deberá ser la siguiente. Utilizar la función CASE y agrupar. 


select u.userid, u.username, u.firstname, u.lastname,
(
case
	when s.sellerid is not null and b.buyerid is not null THEN 'Ambos'
   when s.sellerid is null and b.buyerid is not null THEN 'Comprador'
   when s.sellerid is not null and b.buyerid is null THEN 'Vendedor'
   else 'Ninguno'
end
) as TipoUsuario
from
	users u
    left join sales s on s.sellerid = u.userid -- Entradas donde el usuario es el vendedor
    left join sales b on b.buyerid = u.userid -- Entradas donde el usuario es el comprador
group by u.userid, u.username, u.firstname, u.lastname;


-- Pregunta 3.13 Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
-- Explicar su objetivo en los comentarios de la plantilla .sql

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

DELIMITER \ /*Cambia el delimitador estándar (;) al delimitador $$. Esto es necesario para definir bloques como funciones y procedimientos en MySQL.*/

CREATE FUNCTION NombreResumido(nombre VARCHAR(255), apellido VARCHAR(255)) /*Crea una función llamada NombreResumido*/
RETURNS VARCHAR(255)
DETERMINISTIC /*Especifica que la función es determinística, lo que significa que siempre devolverá el mismo resultado para los mismos parámetros de entrada.*/
BEGIN
    /*Concatenar la inicial del nombre, un punto y el apellido en mayúsculas*/
    RETURN CONCAT(UCASE(LEFT(nombre, 1)), '. ', UCASE(apellido)); /*Obtiene la inicial del 'nombre' (LEFT), la convierte a mayúscula (UCASE), y concatena con un punto y el 'apellido' convertido a mayúsculas.*/
END; /*Fin de la definición de la función.*/

-- Probamos con nuestro nombre

SELECT NombreResumido("Marius", "Ciurana") AS Nombre_Resumido;

-- Probamos con la tabla users

SELECT userid, username, NombreResumido(firstname, lastname) AS Nombre_Resumido 
FROM users; 

-- Pregunta 3.15 Actualizar el campo VIP de la tabla de usuarios a sí a aquellos usuarios que hayan comprado 
-- más de 10 tickets para los eventos o aquellos que hayan vendido más de 25 tickets.

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


-- Pregunta 3.17 La siguiente instrucción:

/*update mytable
set mycolumn = str_to_date(
concat(
   floor(1 + rand() * (12-1)), '-',
   floor(1 + rand() * (28-1)), '-',
   floor(1 + rand() * (1998-1940) + 1940)),'%m-%d-%Y');*/


UPDATE users
SET birthdate = STR_TO_DATE(
    CONCAT(
        FLOOR(1 + RAND() * (12 - 1)), '-', -- Mes aleatorio entre 1 y 12
        FLOOR(1 + RAND() * (28 - 1)), '-', -- Día aleatorio entre 1 y 28
        FLOOR(1940 + RAND() * (1998 - 1940))), '%m-%d-%Y'); -- Año aleatorio entre 1940 y 1998

-- permite actualizar un campo fecha de una tabla con fechas aleatorias (en este caso el año de nacimiento estaría 
-- en el rango 1998-1940, y los días entre 1 y 28).
-- Sintaxis: select floor(rand()*(end - start) + start);
-- Actualizar el campo birthdate de la tabla users, creado en el P1.

-- Pregunta 3.18 Crear una función UDF llamada Kit_Eventos. Se regalará un kit a aquellos usuarios VIP que cumplan años 
-- durante el mes (que recibirá la función por parámetro). La función devolverá "Kit" o "-". Hacer una consulta pertinente
-- para probar la función.

DELIMITER \

CREATE FUNCTION Kit_Eventos(Birthdate DATE, Mes_actual INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    -- Declaramos la variable 'Resultado' que almacenará el valor de retorno.
    DECLARE Resultado VARCHAR(20);
    
    -- Verificamos si el mes de la fecha de nacimiento del usuario coincide con el mes actual.
    IF MONTH(Birthdate) = Mes_actual THEN
        -- Si el mes coincide, asignamos 'Kit' como valor de retorno.
        SET Resultado = 'Kit';
    ELSE
        -- Si el mes no coincide, asignamos '-' como valor de retorno.
        SET Resultado = '-';
    END IF;

    -- Devolvemos el resultado de la evaluación.
    RETURN Resultado;
END;


SELECT 
    firstname, birthdate, VIP,                       
    Kit_Eventos(birthdate, MONTH(CURRENT_DATE())) AS Resultado -- Llama a la función 'Kit_Eventos' para determinar si el usuario recibe un kit.
FROM users
WHERE VIP = 'Sí' AND MONTH(birthdate) = MONTH(CURRENT_DATE()); -- Filtra solo usuarios VIP que cumplen años en el mes actual.

-- 3.19 Inventar una función UDF que permita optimizar las operaciones de la Base de Datos. Justificarla.
/*Se crea una subconsulta que devuelve la categoria musical más comprada por un usuario. 
Esto puede ser útil a la hora de analizar el mercado para tener un mejor enfoque de negocio en la venta de entradas.*/
DELIMITER // 

CREATE FUNCTION categoria_mas_comprada (uid INT) /*Se crea la función llamda categoria más vendida que recibirá un parámetro de tipo entero (id de usuario)*/
RETURNS VARCHAR(10) /*La función devuelve el nombre de categoría, máximo 10 caracteres que es la misma longitud que tiene la columna catname en la tabla categoría*/
DETERMINISTIC /*La función devolverá la misma salida para los mismos parámetros de entrada */
READS SQL DATA /*La función es de solo lectura  ya que utiliza la consulta SELECT*/
BEGIN
	DECLARE mejor_categoria VARCHAR(10); /*Se declara la variable que almacenará el nombre de categoría */
    SELECT c.catname /*Se extrae el nombre de la categoría de la tabla category y se inserta en la variable mejor_cateogria */
    INTO mejor_categoria 
    FROM sales s 
    JOIN listing l ON s.listid = l.listid /*Combino la tabla sales con la tabla listing donde listid es PK en la tabla listing y FK en la tabla sales*/
    JOIN event e ON l.eventid = e.eventid /*Combino la tabla listing con la tabla event donde eventid es PK en la tabla event y FK en la tabla listing */
    JOIN category c ON e.catid = c.catid /*Combino la tabla event con la tabla category donde catid es PK de la tabla category y FK en la tabla event */
    WHERE s.buyerid = uid /*Se filtan los registros para seleccionar el buyerid que coincida con buyerid recibido como parametro por la función*/
    GROUP BY c.catname
    ORDER BY COUNT(*) DESC
    LIMIT 1;
    
    RETURN mejor_categoria;
END//

DELIMITER ;

/*Para comprobar la función se crea la consulta con la tabla users, pasandole a la función el parámetro de userid*/
SELECT 
	u.userid,
    u.username,
    u.firstname,
    u.lastname,
    categoria_mas_comprada (u.userid) AS 'categoria preferida'
FROM users u
WHERE categoria_mas_comprada(u.userid) IS NOT NULL;

DROP FUNCTION IF EXISTS `categoria_mas_comprada`;


-- Variables de @usuario

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


-- Pregunta 3.21 Crear dos variables de usuario. Una denominada @esVIP y la otra @monthbirthday.
-- Asignar un valor a la variable @esVIP (true / false).
-- Asignar el valor del mes en curso a la variable @monthbirthday

set @esVIP = true;
set @monthbirthday = MONTH(curdate());

-- Pregunta 3.22 Hacer una consulta basada en la vista cumpleanhos que utilice las variables de usuario para filtrar los 
-- cumpleañeros del mes en @monthbirthday cuyo valor en el campo VIP coincida con el asignado a la variable @esVIP.
-- Consulta basada en la vista cumpleanhos
SELECT userid, username, NombreResumido, VIP, dia, mes, birthdate
FROM cumpleanhos
WHERE VIP = @esVIP AND mes = @monthbirthday;

