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

-- Pregunta 2.19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total
SELECT 
CONCAT(YEAR(s.saletime), ' Trimestre', QUARTER(s.saletime)) AS trimestre, -- CONCAT concatena el año junto con el trimestre en una misma columna. QUARTER divide el "saletime" en cuatro. La columna se mostrará como trimestre.
ROUND(AVG(s.pricepaid), 2) AS precio_promedio_por_trimestre, -- Al utilizar cláusula GROUP BY y QUARTER, la media de "pricepaid" se calcula para cada una de las cuatro partes. La columna se mostrará como precio promedio por trimestre.
(SELECT ROUND(AVG(pricepaid), 2) FROM sales) AS precio_promedio_total -- La subconsulta calculará la media del "pricepaid" total de la tabla "sales". La columna se mostrará como precio promedio total. 
FROM sales s
GROUP BY YEAR(s.saletime), QUARTER(s.saletime); -- Con la cláusula GROUP BY.. QUARTER, se asegura que la medía de pricepaid se haga por cada cuatrimestre.

-- 2.20 Muestra el total de tickets de entradas compradas de Shows y Conciertos.

SELECT c.catgroup, -- 
COALESCE (SUM(s.qtysold), 0) AS tickets_vendidos -- Se hace la suma de la columna "qtysold". Con la cláusula GROUP BY, se asegura que la suma se haga de cada categoría por separado. La columna se muestra como tickets_vendidos.
FROM category c 
LEFT JOIN event e ON e.catid = c.catid -- Se une la tabla "event" con tabla "category" la columna común es "catid" 
LEFT JOIN sales s ON e.eventid = s.eventid -- Se une la tabla "sales" con tabla "event" la columna común es "eventid"
WHERE c.catgroup IN ('Concerts', 'Shows') -- Se filtran los datos de columna "catgroup" de la tabla "category" por "Concerts y Shows" 
GROUP BY c.catgroup -- La clausula asegura que la suma de "qtysold" se haga por para cada grupo por separado.
ORDER BY tickets_vendidos DESC;

--Pregunta 2.21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.

SELECT e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity, 
SUM(s.qtysold) AS total_tickets_vendidos -- Se hace la suma de "qtysold", debido a la cláusula GROUP BY "eventid", se hará la suma de cada evento.
FROM event e
JOIN venue v ON e.venueid = v.venueid -- Se une la tabla "event" con la tabla "venue", la columna común es "venueid"
JOIN sales s ON e.eventid = s.eventid -- Se une la tabla "sales" con la tabla "event", la columna común es "eventid"
GROUP BY e.eventid -- La cláusula agrupa cada evento almacenado en "eventid"
ORDER BY total_tickets_vendidos DESC -- Se ordenan los resultados por el número de tickets vendidos de menor a mayor.
LIMIT 1; -- Se muestra solo la primera fila, la de mayor número de tickets vendidos. 

