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
-- Pregunta 1.5 Revisar los comentarios en las tablas y generar dos restricciones de tipo check para controlar la integridad de los datos.

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


