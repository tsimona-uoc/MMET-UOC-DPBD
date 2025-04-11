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

-- Pregunta 3.10 Mostrar cuántos usuarios que han comprado entradas para los eventos de la semana 9 son "locales". 
-- Se considera que un usuario es local, si el nombre de la ciudad donde se realiza el evento es igual a la ciudad natal 
-- del usuario, de lo contrario es un visitante.
-- Utilizar la función IF y agrupar.


-- Pregunta 3.11 Eliminar de la tabla users a todos aquellos usuarios registrados que no hayan comprado ni vendido 
-- ninguna entrada. Antes de eliminarlos, copiarlos a una tabla denominada backup_users para poder recuperarlos en caso 
-- de ser necesario.

-- Pregunta 3.12 Mostrar una lista de usuarios donde se especifique para cada usuario si éste es un comprador 
-- (sólo ha comprado entradas), un vendedor (sólo ha vendido entradas) o ambos.
-- La salida de la consulta deberá ser la siguiente. Utilizar la función CASE y agrupar. 


-- Pregunta 3.13 Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
-- Explicar su objetivo en los comentarios de la plantilla .sql


-- Funciones UDF

-- Pregunta 3.14 Crear una función UDF llamada NombreResumido que reciba como parámetros un nombre y un apellido y retorne
-- un nombre en formato (Inicial de Nombre + "." + Apellido en mayúsculas. Ejemplo: L. LANAU).
-- Probar la función en una consulta contra la tabla de socios y enviando directamente el nombre con tus datos en forma 
-- literal, por ejemplo escribir:
-- SELECT NombreResumido("Rita", "de la Torre") para probar la función, deberá devolver: R. DE LA TORRE.

-- Pregunta 3.15 Actualizar el campo VIP de la tabla de usuarios a sí a aquellos usuarios que hayan comprado 
-- más de 10 tickets para los eventos o aquellos que hayan vendido más de 25 tickets.

-- Pregunta 3.16 Crear una función UDF llamada Pases_cortesía. Se regalará 1 pase de cortesía por cada 10 tickets comprados
-- o vendidos, a los usuarios VIP. Hacer una consulta denominada pases_usuarios para probar la función y guardarla como 
-- una vista. Los campos de la misma deberán ser: userid, username, NombreResumido, número de pases.

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
