-- 3.10. Mostrar cuántos usuarios que han comprado entradas para los eventos de la semana 9 son "locales". 
-- Se considera que un usuario es local, si el nombre de la ciudad donde se realiza el evento es igual a la ciudad natal del usuario, de lo contrario es un visitante.

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

-- 3.14 Crear una función UDF llamada NombreResumido que reciba como parámetros un nombre y un apellido y retorne un nombre en formato (Inicial de Nombre + "." + Apellido en mayúsculas. Ejemplo: L. LANAU).
-- Probar la función en una consulta contra la tabla de socios y enviando directamente el nombre con tus datos en forma literal, por ejemplo escribir:
-- SELECT NombreResumido("Rita", "de la Torre") para probar la función, deberá devolver: R. DE LA TORRE

DELIMITER //

CREATE FUNCTION NombreResumido (firstname VARCHAR(30), lastname VARCHAR(30))
RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN 
	DECLARE inicial_nombre CHAR(1);
    DECLARE apellido_mayuscula VARCHAR(30);
    DECLARE nombre_completo VARCHAR(40);
    
    SET inicial_nombre = UPPER(LEFT(firstname, 1));
    SET apellido_mayuscula = UPPER(lastname);
    SET nombre_completo = CONCAT(inicial_nombre, ' ', apellido_mayuscula);
    RETURN nombre_completo;
END //

DELIMITER ;

SELECT NombreResumido("Evarishtu", "Dongua") AS Nombre;

SELECT NombreResumido(firstname, lastname) AS 'Nombre Completo'
FROM users;

DROP FUNCTION IF EXISTS `NombreResumido`;

SHOW FUNCTION STATUS WHERE Db = 'fp_204_23';

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