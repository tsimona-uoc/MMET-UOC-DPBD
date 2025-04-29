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

--COnsulta optimizada

-- 1. Primero aseguramos índices adecuados
CREATE INDEX idx_sales_buyerid ON sales(buyerid); /*Acelera la búsqueda de coincidencias durante el JOIN o NOT EXISTS*/

-- 2. Creamos la tabla
CREATE TABLE users_without_buys (
	userid int,
    firstname varchar(30),
    lastname varchar(30),
    phone char(14)
    );

-- 3. Usamos NOT EXISTS en lugar de LEFT JOIN (a veces más eficiente)
INSERT INTO users_without_buys (userid, firstname, lastname, phone)
SELECT userid, firstname, lastname, phone
FROM users u
WHERE NOT EXISTS ( /*En muchos casos, MySQL optimiza mejor NOT EXISTS que LEFT JOIN + IS NULL*/
    SELECT 1 
    FROM sales s 
    WHERE s.buyerid = u.userid
);


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

-- Consulta optimizada

-- Asegurar índices primero (si no existen)
CREATE INDEX idx_event_catid ON event(catid);
CREATE INDEX idx_listing_eventid ON listing(eventid);
CREATE INDEX idx_sales_eventid ON sales(eventid);

SELECT 
    c.catgroup,
    COALESCE(SUM(s.qtysold), 0) AS tickets_vendidos,
    COALESCE(SUM(l.numtickets), 0) - COALESCE(SUM(s.qtysold), 0) AS tickets_sin_vender
FROM category c
LEFT JOIN event e ON e.catid = c.catid
LEFT JOIN (
    SELECT eventid, numtickets
    FROM listing
) l ON l.eventid = e.eventid
LEFT JOIN (
    SELECT eventid, qtysold
    FROM sales
) s ON s.eventid = e.eventid
GROUP BY c.catgroup
ORDER BY tickets_vendidos DESC;

-- Creamos una vista sobre los tickets vendidos ya que será una consulta frecuente en la BBDD ya que simplifica la consulta principal, haciéndola más legible.

CREATE VIEW vista_tickets_vendidos AS
SELECT 
    e.eventid,
    COALESCE(SUM(s.qtysold), 0) AS tickets_vendidos
FROM event e
LEFT JOIN sales s ON e.eventid = s.eventid
GROUP BY e.eventid;

-- Podemos usar esta consulta usando la vista creada lo que resulta más eficaz

SELECT 
    c.catgroup,
    vt.tickets_vendidos,
    COALESCE(SUM(l.numtickets), 0) - vt.tickets_vendidos AS tickets_sin_vender
FROM category c
LEFT JOIN event e ON e.catid = c.catid
LEFT JOIN listing l ON l.eventid = e.eventid
LEFT JOIN vista_tickets_vendidos vt ON e.eventid = vt.eventid
GROUP BY c.catgroup
ORDER BY vt.tickets_vendidos DESC;

-- Pregunta 2.22 Crea una vista con los eventos del mes de la tabla que coincida con el mes actual. Grabar la vista con el nombre Eventos del mes
create view EventosDelMes AS select * from event where MONTH(starttime) = MONTH(CURDATE());
-- Se selecciona el mes de cada entrada y se filtra para que ese mes sea igual al mes en el que se lanza la consulta

-- Consulta optimizada
-- Primero, crear un índice funcional si tu versión de MySQL lo permite (8.0+)
CREATE INDEX idx_event_starttime_month ON event((MONTH(starttime)), ((YEAR(starttime)));

-- Versión optimizada de la vista
CREATE VIEW EventosDelMes AS
SELECT * 
FROM event 
WHERE /* Rango de fechas en lugar de función MONTH:*/
    starttime >= DATE_FORMAT(CURDATE(), '%Y-%m-01') /* starttime >= primer_día_del_mes */
    AND starttime < DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'); /* starttime < primer_día_del_mes_siguiente */

    /* Evita mostrar eventos de meses iguales en años diferentes */


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

-- Consulta optimizada

-- Asegurar índices primero (si no existen)
CREATE INDEX IF NOT EXISTS idx_event_venue ON event(venueid);
CREATE INDEX IF NOT EXISTS idx_event_date ON event(dateid);
CREATE INDEX IF NOT EXISTS idx_sales_event ON sales(eventid);
CREATE INDEX IF NOT EXISTS idx_sales_buyer ON sales(buyerid);
CREATE INDEX IF NOT EXISTS idx_date_week ON date(week, dateid);
CREATE INDEX IF NOT EXISTS idx_users_city ON users(city, userid);


SELECT 
    CONCAT(e.eventid, ' - ', e.eventname) AS Evento,
    /* CASE WHEN es más estándar y mejor optimizado que IF */
    COUNT(CASE WHEN u.city = v.venuecity THEN 1 END) AS `Asistentes Locales`, /* COUNT en lugar de SUM(IF): Más eficiente y legible */
    COUNT(CASE WHEN u.city <> v.venuecity THEN 1 END) AS `Asistentes Visitantes` /* COUNT ignora automáticamente los NULLs */
FROM 
    date d /* Comenzamos con la tabla date para aplicar el filtro de semana primero */
    JOIN event e ON d.dateid = e.dateid AND d.week = 9  -- Filtro temprano por semana La condición d.week = 9 se aplica inmediatamente en el JOIN */
    JOIN venue v ON e.venueid = v.venueid
    JOIN sales s ON e.eventid = s.eventid
    JOIN users u ON s.buyerid = u.userid
GROUP BY
    e.eventid, e.eventname
ORDER BY 
    e.eventid;

-- Pregunta 3.15 Actualizar el campo VIP de la tabla de usuarios a sí a aquellos usuarios que hayan comprado 
-- más de 10 tickets para los eventos o aquellos que hayan vendido más de 25 tickets.

ALTER TABLE users
ADD COLUMN VIP VARCHAR(3) DEFAULT 'no';

UPDATE users
SET VIP = 'sí'
WHERE userid IN (
    SELECT buyerid
    FROM sales
    GROUP BY buyerid
    HAVING COUNT(*) > 10

    UNION

    SELECT userid
    FROM listing
    GROUP BY userid
    HAVING COUNT(*) > 25
);

-- Consulta optimizada

-- Primero asegurar índices (si no existen)
CREATE INDEX IF NOT EXISTS idx_sales_buyer ON sales(buyerid);
CREATE INDEX IF NOT EXISTS idx_listing_seller ON listing(userid);

-- Actualización en una sola pasada con JOINs
UPDATE users u
JOIN (
    SELECT userid, 
           SUM(bought) AS total_bought,
           SUM(sold) AS total_sold
    FROM (
        SELECT buyerid AS userid, COUNT(*) AS bought, 0 AS sold
        FROM sales
        GROUP BY buyerid
        
        UNION ALL /* UNION ALL en lugar de UNION: Más eficiente al no eliminar duplicados (innecesario en este contexto) */
        
        SELECT userid, 0 AS bought, COUNT(*) AS sold
        FROM listing
        GROUP BY userid
    ) combined
    GROUP BY userid
    HAVING total_bought > 10 OR total_sold > 25
) vip_users ON u.userid = vip_users.userid
SET u.VIP = 'sí';

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

-- Consulta optimizada

CREATE INDEX idx_sales_buyer ON sales(buyerid);
CREATE INDEX idx_listing_event ON listing(eventid);
CREATE INDEX idx_event_category ON event(catid);

DELIMITER //

CREATE FUNCTION categoria_mas_comprada_opt(uid INT) 
RETURNS VARCHAR(10)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE mejor_categoria VARCHAR(10);
    
    -- Consulta optimizada con índices sugeridos
    SELECT c.catname INTO mejor_categoria
    FROM category c
    WHERE c.catid = (
        SELECT e.catid
        FROM sales s
        JOIN listing l ON s.listid = l.listid
        JOIN event e ON l.eventid = e.eventid
        WHERE s.buyerid = uid
        GROUP BY e.catid
        ORDER BY COUNT(*) DESC
        LIMIT 1
    );
    
    RETURN mejor_categoria;
END//

DELIMITER ;

-- Consulta de prueba optimizada
SELECT 
    u.userid,
    u.username,
    categoria_mas_comprada_opt(u.userid) AS 'categoria_preferida'
FROM users u
WHERE EXISTS ( /* Filtro EXISTS en lugar de llamar a la función en el WHERE Más eficiente al evitar ejecutar la función para todos los usuarios */
    SELECT 1 FROM sales WHERE buyerid = u.userid
);
