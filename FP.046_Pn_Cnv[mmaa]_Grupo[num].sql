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

/* Al intentar crear la FK en la tabla listing que hace referencia al eventid de la tabla event, nos encontramos un error porque
 * hay registros eventid que no coinciden en ambas tablas. Para solucionarlo hacemos los siguientes pasos.
 */

CREATE TABLE listing_bakcup; -- Creamos un backup de la tabla listing para mover los registros en eventid que no coinciden con la tabla event.

INSERT INTO listing_bakcup
SELECT *
FROM listing
WHERE eventid NOT IN (SELECT eventid FROM event); -- Movemos todos los registros de la columna eventid en la tabla listing que no coinciden con los registros de la tabla event.

DELETE FROM listing
WHERE eventid NOT IN (SELECT eventid FROM event); -- Eliminamos los registros que hemos movido a la tabla listing_backup

ALTER TABLE listing
ADD CONSTRAINT fk_listing_event
FOREIGN KEY (eventid) REFERENCES event (eventid)
ON UPDATE CASCADE
ON DELETE RESTRICT; -- Una vez hechos los cambios ya nos deja crear la FK


CREATE TABLE sales_bakcup;

INSERT INTO sales_backup
SELECT *
FROM sales
WHERE eventid NOT IN (SELECT eventid FROM event);

DELETE FROM sales
WHERE eventid NOT IN (SELECT eventid FROM event);

ALTER TABLE sales
ADD CONSTRAINT fk_sales_event
FOREIGN KEY (eventid) REFERENCES event (eventid)
ON UPDATE CASCADE
ON DELETE RESTRICT;


INSERT INTO sales_backup
SELECT *
FROM sales
WHERE listid NOT IN (SELECT listid FROM listing);

DELETE FROM sales
WHERE listid NOT IN (SELECT listid FROM listing);

ALTER TABLE sales
ADD CONSTRAINT fk_sales_listing
FOREIGN KEY (listid) REFERENCES listing (listid)
ON UPDATE CASCADE
ON DELETE RESTRICT; 

/*Se quiere referenciar mediante buyerid y sellerid a la tabla user. Sin embargo la tabla user no contiene 
 *las columnas buyerid y sellerid, por tanto se referencian mediante userid de la tabla users. * 
 */

ALTER TABLE sales
ADD CONSTRAINT fk_sales_buyer
FOREIGN KEY (buyerid) REFERENCES users (userid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE sales
ADD CONSTRAINT fk_sales_seller
FOREIGN KEY (sellerid) REFERENCES users (userid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE listing
ADD CONSTRAINT fk_listing_seller
FOREIGN KEY (sellerid) REFERENCES users (userid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE event
ADD CONSTRAINT fk_event_venue
FOREIGN KEY (venueid) REFERENCES venue (venueid)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Pregunta 1.5 Revisar los comentarios en las tablas y generar dos restricciones de tipo check para controlar la integridad de los datos.
/*1.5.1.1 Restricción de columna "username" en tabla "users" - solo valores alfanumericos, usuario de 8 caracteres*/
ALTER TABLE `users`
	ADD CONSTRAINT `check_username_Alfanumerico`
    CHECK (LENGTH(`username`) = 8 AND `username` REGEXP '^[a-z A-Z 0-9]+$'); 	

/*1.5.2.1 Restricción de columna "venueseats" en la tabla "venue" - capacidad máxima en el recinto de 73200*/
ALTER TABLE `venue`
	ADD CONSTRAINT `check_venueseats_MaximoAsientos`
    CHECK (`venueseats` >= 0 AND `venueseats` <= 73200);

/*1.5.3.1 Restricción de columna "qtysold" en la tabla "sales", máximo de 8 tickets vendidos por lote*/
ALTER TABLE `sales`
	ADD CONSTRAINT `check_qtysold_maxEntradas`
    CHECK (`qtysold` BETWEEN '1' AND '8'); /*Opciones alternativas: CHECK (`qtysold` IN ('1', '2', '3', '4', '5', '6', '7', '8')); CHECK (`qtysold` >= '1' AND `qtysold` <= '8');*/

-- Pregunta 1.6 Revisar los comentarios en las tablas y cambiar los campos que así lo requieran, por campos autocalculados.

/*Después de analizar los datos de las distintas tablas, los campos que requieren esta madificación serían:
 *'totalprice' en la tabla 'listing' 
 *'comissions' en la tabla 'sales'
 */

ALTER TABLE listing
DROP COLUMN totalprice;

ALTER TABLE listing
ADD COLUMN totalprice DECIMAL(8,2) GENERATED ALWAYS AS (numtickets * priceperticket) VIRTUAL after numtickets; 

ALTER TABLE sales
DROP COLUMN comission;

ALTER TABLE sales 
ADD COLUMN commission DECIMAL(8,2) GENERATED ALWAYS AS (pricepaid * 0.15) VIRTUAL after pricepaid;

/* 
-- Pregunta 1.7 Agregar dos campos adicionales a la Base de Datos que enriquezca la información de la misma. Justificar.
*/
ALTER TABLE `event` add column `enddate` DATETIME DEFAULT NULL;
/*
* Agregamos el campo enddate de tipo DATETIME nulable, en la tabla event. Esto permitira guardar el instante en el que se finalizó el evento.
* Posible uso: Analisis de datos y optimización de espacio de tiempo reservado de futuros eventos (o estimación de la duración)
*/
ALTER TABLE users ADD COLUMN total_commission DECIMAL (8, 2) DEFAULT (0.0);
/**
* Agregamos el campo total_comission para almacenar la comision total generada por este usuario como comprador
*/

DELIMITER //
CREATE TRIGGER TR_UpdateCommissionOnUpdate BEFORE UPDATE ON `sales` FOR EACH ROW
BEGIN
UPDATE users 
SET total_commission = (SELECT COALESCE(SUM(commission), 0) FROM sales WHERE sellerid = NEW.sellerid)
WHERE userid = NEW.sellerid;
END;

DELIMITER //
CREATE TRIGGER TR_UpdateCommissionOnDelete AFTER DELETE ON sales FOR EACH ROW
BEGIN
UPDATE users 
SET total_commission = (SELECT COALESCE(SUM(commission), 0) FROM sales WHERE sellerid = OLD.sellerid)
WHERE userid = OLD.sellerid;
END;

DELIMITER //
CREATE TRIGGER TR_UpdateCommissionOnInsert BEFORE INSERT ON `sales` FOR EACH ROW
BEGIN
UPDATE users 
SET total_commission = (SELECT COALESCE(SUM(commission), 0) FROM sales WHERE sellerid = NEW.sellerid)
WHERE userid = NEW.sellerid;
END;

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


