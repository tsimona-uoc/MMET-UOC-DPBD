-- Pregunta 2.17 Mostrar aquellas fechas en las cuales no ha habido ningún evento. Se deberá mostrar los campos caldate y holiday

SELECT date.caldate, date.holiday
FROM date
LEFT JOIN event ON date.dateid = event.dateid
WHERE event.dateid IS NULL; /* No devuelve ninguna fecha ya que en todas las fechas hubo algun evento */

-- Pregunta 2.17 - Optimizada:

-- 1. Crear índice en event.dateid
CREATE INDEX idx_event_dateid ON event(dateid);

-- 2. Consulta optimizada usando NOT EXISTS (evita el materializar el join completo):
SELECT
  d.caldate,
  d.holiday
FROM
  `date` AS d
WHERE
  NOT EXISTS (
    SELECT 1
    FROM event AS e
    WHERE e.dateid = d.dateid
  );

-- Pregunta 2.21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.
SELECT e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity,
SUM(s.qtysold) AS total_tickets_vendidos -- Se hace la suma de "qtysold", debido a la cláusula GROUP BY "eventid", se hará la suma de cada evento.
FROM event e
JOIN venue v ON e.venueid = v.venueid -- Se une la tabla "event" con la tabla "venue", la columna común es "venueid"
JOIN sales s ON e.eventid = s.eventid -- Se une la tabla "sales" con la tabla "event", la columna común es "eventid"
GROUP BY e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity -- La cláusula agrupa cada evento almacenado en "eventid"
ORDER BY total_tickets_vendidos DESC -- Se ordenan los resultados por el número de tickets vendidos de menor a mayor.
LIMIT 1; -- Se muestra solo la primera fila, la de mayor número de tickets vendidos.

-- Pregunta 2.21 - Optimizada:

-- 1. Indice para acelerar agregación sobre sales:

CREATE INDEX idx_sales_eventid_qty ON sales(eventid, qtysold);

-- 2. Pre-agregación en subconsulta (reduce el volumen de datos antes del JOIN/ORDER BY):
SELECT
  e.eventid,
  e.starttime,
  e.eventname,
  v.venuename,
  v.venuecity,
  t.total_sold
FROM event AS e
JOIN venue AS v
  ON e.venueid = v.venueid
JOIN (
  SELECT
    eventid,
    SUM(qtysold) AS total_sold
  FROM sales
  GROUP BY eventid
) AS t
  ON e.eventid = t.eventid
ORDER BY
  t.total_sold DESC
LIMIT 1;


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

-- Pregunta 3.9 - Optimizada:

-- 1. Añadir columnas generadas y su índice para filtrar sin función en la cláusula WHERE:
ALTER TABLE `date`
ADD COLUMN year_generated  INT AS (YEAR(caldate))  STORED,
ADD COLUMN month_generated INT AS (MONTH(caldate)) STORED,
ADD INDEX idx_date_year_month (year_generated, month_generated),
ADD INDEX idx_date_week (week);

-- 2. Consulta optimizada usando esas columnas:
SELECT
  e.eventid,
  e.eventname,
  d.caldate,
  d.week,
  CASE
    WHEN d.week = WEEK(CURRENT_DATE()) THEN 'Si'
    ELSE 'No'
  END AS coincideSemana
FROM event AS e
JOIN `date` AS d
  ON e.dateid = d.dateid
WHERE
  d.year_generated  = YEAR(CURRENT_DATE())
  AND d.month_generated = MONTH(CURRENT_DATE())
ORDER BY
  d.week;

-- Pregunta 3.13 Inventar una consulta que haga uso de una de las siguientes funciones: COALESCE, IFNULL, NULLIF.
-- Explicar su objetivo en los comentarios de la plantilla .sql

SELECT userid, username,
    COALESCE(phone, 'Teléfono no disponible') AS contact_info
FROM users;

-- Pregunta 3.13 - Optimizada:
-- TBD

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

-- Pregunta 3.14 - Optimizada:
-- TBD

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

-- Pregunta 3.18 - Optimizada:
-- TBD

-- Pregunta 3.22 Hacer una consulta basada en la vista cumpleanhos que utilice las variables de usuario para filtrar los 
-- cumpleañeros del mes en @monthbirthday cuyo valor en el campo VIP coincida con el asignado a la variable @esVIP.
-- Consulta basada en la vista cumpleanhos
SELECT userid, username, NombreResumido, VIP, dia, mes, birthdate
FROM cumpleanhos
WHERE VIP = @esVIP AND mes = @monthbirthday;

-- Pregunta 3.22 - Optimizada:
-- TBD