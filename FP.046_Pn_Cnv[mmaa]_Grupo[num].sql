-- PLANTILLA DE ENTREGA DE LA PARTE PRÁCTICA DE LAS ACTIVIDADES
-- --------------------------------------------------------------
-- Actividad: AAn(P1)
--
-- Grupo: Cnv0222_Grupo06: [MMET]
-- 
-- Integrantes: 
-- 1. Maria Ricart Martínez
-- 2. Evarishtu Dongua Kuzin
-- 3. Temis Simon Antonio
-- 4. Marius Ciurana Rodríguez
--
-- Database: [fp_204_23]
-- --------------------------------------------------------------
/* Utilizar la misma numeración de preguntas de la actividad. Ejemplos: */

--
-- Pregunta 5.1. Indicar el número de empleados registrados en la Base de Datos.
--
SELECT COUNT(*) AS NumeroEmpleados FROM EMPLEADO;

--
-- Pregunta 5.2. Mostrar todos los empleados ordenados por el departamento al cual pertenecen.
--
SELECT d.Departamento, e.Nombre, e.Apellido1, e.Apellido2, e.DNI
FROM DEPARTAMENTO AS d INNER JOIN EMPLEADO AS e
ON d.pkDepartamento = e.fkDepartamento
ORDER BY d.Departamento;

/* Los comentarios a las preguntas, indicarlos en este formato después de la instrucción SQL correspondiente.
 * Ejemplo: 
 * Usamos las tablas DEPARTAMENTO y EMPLEADO
 * con el alias d y e respectivamente.
 */

--
-- Pregunta 5.3. etc...
--

-- Pregunta 1.1 Importar las tablas y el script de control que se encuentra en los archivos .sql con el mismo nombre.

-- Pregunta 1.2 Hacer un análisis del contenido de las tablas. Para ello, cada una de las columnas de las mismas, se encuentran comentadas. También se puede hacer uso de las instrucciones que se encuentran en el script de control.

-- Pregunta 1.3 Crear dos campos adicionales en la tabla users: VIP (enum: sí, no; default: no) y birthdate (date). Se utilizarán posteriormente en próximos productos.

ALTER TABLE users
ADD COLUMN VIP ENUM('sí', 'no') DEFAULT 'no',
ADD COLUMN birthdate DATE;

/* Usamos ALTER TABLE para modificar la tabla users y añadir las columnas "VIP" y "birthdate"
 * mediante ADD COLUMN. 
 */

-- Pregunta 1.4 Relacionar las tablas de la Base de Datos tomando en cuenta aquellas columnas que tienen en su descripción el texto Referencia de clave externa a la tabla xxx.. Al crear las claves foráneas, agregar las cláusulas ON UPDATE y ON DELETE pertinentes, justificando con un comentario cada decisión, con comentarios en la plantilla.

ALTER TABLE event
ADD CONSTRAINT fk_event_category
FOREIGN KEY (catid) REFERENCES category(catid)
ON UPDATE CASCADE -- Si el ID en la tabla category cambia, se actualiza automáticamente en la tabla event.
ON DELETE RESTRICT; -- Evita eliminar una categoría si está siendo referenciada por algún evento.

ALTER TABLE event
ADD CONSTRAINT fk_event_date
FOREIGN KEY (dateid) REFERENCES date(dateid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE sales
ADD CONSTRAINT fk_sales_date
FOREIGN KEY (dateid) REFERENCES date(dateid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE listing
ADD CONSTRAINT fk_listing_date
FOREIGN KEY (dateid) REFERENCES date(dateid)
ON UPDATE CASCADE
ON DELETE RESTRICT;




-- Pregunta 1.5 Revisar los comentarios en las tablas y generar dos restricciones de tipo check para controlar la integridad de los datos.
/*1.5.1.1 Restricción de columna "username" en tabla "users" - solo valores alfanumericos, usuario de 8 caracteres*/
ALTER TABLE `users`
	ADD CONSTRAINT `check_username_Alfanumerico`
    CHECK (LENGTH(`username`) = 8 AND `username` REGEXP '^[a-z A-Z 0-9]+$'); 
/*1.5.1.2 Para eliminar el CONSTRAINT creado*/
ALTER TABLE `users` DROP CONSTRAINT `check_username_Alfanumerico`;	
START TRANSACTION;
/*1.5.1.2 Comprobación de la restricción check_username_Alfanumerico*/
INSERT INTO `users`(userid, username)
	VALUES (49991, '10');
COMMIT;
ROLLBACK;	

/*1.5.2.1 Restricción de columna "venueseats" en la tabla "venue" - capacidad máxima en el recinto de 73200*/
ALTER TABLE `venue`
	ADD CONSTRAINT `check_venueseats_MaximoAsientos`
    CHECK (`venueseats` >= 0 AND `venueseats` <= 73200);
/*1.5.2.2 Debería dar error, ya que existen registros cuyo número de asientos excede 73200
como solución se propone modificar aquellos registros con aforo superior a 73200, limitándolos a 73200*/
START TRANSACTION;
UPDATE venue
	SET venueseats = 73200
	WHERE venueseats > 73200;
COMMIT;
ROLLBACK;

/*1.5.3.1 Restricción de columna "qtysold" en la tabla "sales", máximo de 8 tickets vendidos por lote*/
ALTER TABLE `sales`
	ADD CONSTRAINT `check_qtysold_maxEntradas`
    CHECK (`qtysold` BETWEEN '1' AND '8'); /*Opciones alternativas: CHECK (`qtysold` IN ('1', '2', '3', '4', '5', '6', '7', '8')); CHECK (`qtysold` >= '1' AND `qtysold` <= '8');*/
/*1.5.3.2 Comprobación de la restriccion `check_qtysold_maxEntradas`*/
START TRANSACTION;
INSERT INTO `sales`(salesid, listid, sellerid, buyerid, eventid, dateid, qtysold, pricepaid, commission, saletime)
	VALUES (172457, 1, 1, 1, 1, 1, 10, 1.1, 1.1, '2008-06-06 03:00:16');
COMMIT;
ROLLBACK;
-- Pregunta 1.6 Revisar los comentarios en las tablas y cambiar los campos que así lo requieran, por campos autocalculados.

-- Pregunta 1.7 Agregar dos campos adicionales a la Base de Datos que enriquezca la información de la misma. Justificar.
alter table `event` add column `enddate` DATETIME DEFAULT NULL;
/*
* Agregamos el campo enddate de tipo DATETIME nulable, en la tabla event. Esto permitira guardar el instante en el que se finalizó el evento.
* Posible uso: Analisis de datos y optimización de espacio de tiempo reservado de futuros eventos (o estimación de la duración)
*/
alter table `users` add column birthdate DATETIME DEFAULT NULL AFTER phone;
/*
* Agregamos el campo birthdate de tipo DATETIME (por defecto NULL ya que no se dispone de las fechas de nacimiento) justo antes de la columna "phone".
* Posible uso: Analisis de datos, comprobar el publico objetivo de cada evento por edades.
*/

-- Pregunta 1.8 Crear un disparador que al actualizar el campo username de la tabla users revise si su contenido contiene mayúsculas, minúsculas, digitos y alguno de los siguientes símbolos: -_#@. De no ser así, no permitir la actualización.

DELIMITER //
CREATE TRIGGER TR_ValidUsernameUpdate BEFORE UPDATE ON `users` FOR EACH ROW
BEGIN
IF NOT NEW.username REGEXP '^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[-_#@])[A-Za-z0-9\-_#@]+$' THEN
	SIGNAL SQLSTATE '99001'
    SET MESSAGE_TEXT = 'El usuario debe contener al menos un caracter de cada tipo: mayuscula, minuscula, digito, (-_#@)';
END IF;
END;

/*
* Se crea el trigger TR_ValidUsernameUpdate que se lanza antes de actualizar la tabla users. Este trigger comprueba que el campo username que se va a actualizar cumple la expresión regular, de no ser asi lanza un mensaje indicando el error.
*/

-- Pregunta 1.9 Diseñar un disparador que prevenga que el campo email de la tabla users tenga un formato correcto al actualizar o insertar un nuevo email.

DELIMITER //
CREATE TRIGGER TR_VALIDMAILONINSERT BEFORE INSERT ON `users` FOR EACH ROW
BEGIN
	IF NOT NEW.email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,63}$' THEN
		SIGNAL SQLSTATE '99002'
		SET message_text = 'No se cumple la expresión regular de correo electronico valido.';
    END IF;
END;

DELIMITER //
CREATE TRIGGER TR_VALIDMAILONUPDATE BEFORE UPDATE ON `users` FOR EACH ROW
BEGIN
	IF NOT NEW.email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,63}$' THEN
		SIGNAL SQLSTATE '99003'
		SET message_text = 'No se cumple la expresión regular de correo electronico valido.';
    END IF;
END;

/*
* Dado que mysql no permite crear un trigger unico para ambas operaciones (UPDATE E INSERT), se crean dos triggers:
* TR_VALIDMAILONINSERT -> Ejecutado cuando se inserta un nuevo email (una fila nueva)
* TR_VALIDMAILONUPDATE -> Ejecutado cuando se actualiza un email existente (email = ****)
* En ambos triggers se comprueba que se cumple la expresión regular definida.
*/

-- Pregunta 1.10 Inventar una restricción que sirva de utilidad para mantener la integridad de la Base de Datos.
/*1.10.1.1 Restricción que no permita "username" repetidos*/
ALTER TABLE users ADD CONSTRAINT unico_username UNIQUE (username);
/*1.10.1.2 Para eliminar la restricción*/
ALTER TABLE users DROP CONSTRAINT unico_username;

/*Restricción de columna "numtickets" tabla "listing" que no permita valores negativos*/
ALTER TABLE `listing`
	ADD CONSTRAINT `check_numtickets_positivos`
    CHECK (`numtickets` >= 0);
/*Para comprobar la restricción "check_numtickets_positivos"*/
START TRANSACTION;
INSERT INTO `listing`(listid, numtickets)
	VALUES (19118, -2);
COMMIT;
ROLLBACK;


