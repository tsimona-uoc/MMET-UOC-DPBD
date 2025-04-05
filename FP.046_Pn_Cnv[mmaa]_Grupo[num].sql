-- 18 Mostrar la cantidad de tickets vendidos y sin vender para las diferentes categorías de eventos


SELECT c.catgroup, 
COALESCE (SUM(s.qtysold), 0) AS tickets_vendidos,
COALESCE (SUM(l.numtickets), 0) - COALESCE(SUM(s.qtysold)) AS tickets_sin_vender
FROM category c
LEFT JOIN event e ON e.catid = c.catid
LEFT JOIN listing l ON l.eventid = e.eventid
LEFT JOIN sales s ON e.eventid = s.eventid
GROUP BY c.catgroup
ORDER BY tickets_vendidos DESC;

-- 19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total

SELECT 
CONCAT(YEAR(s.saletime), 'Q', QUARTER(s.saletime)) AS trimestre,
ROUND(AVG(s.pricepaid), 2) AS precio_promedio_por_trimestre,
(SELECT ROUND(AVG(pricepaid), 2) FROM sales) AS precio_promedio_total
FROM sales s
GROUP BY YEAR(s.saletime), QUARTER(s.saletime)
ORDER BY YEAR(s.saletime), QUARTER(s.saletime);

-- 20 Muestra el total de tickets de entradas compradas de Shows y Conciertos.

SELECT c.catgroup,
COALESCE (SUM(s.qtysold), 0) AS tickets_vendidos
FROM category c
LEFT JOIN event e ON e.catid = c.catid
LEFT JOIN sales s ON e.eventid = s.eventid
WHERE c.catgroup IN ('Concerts', 'Shows')
GROUP BY c.catgroup
ORDER BY tickets_vendidos DESC;

-- 21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.

SELECT e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity,
SUM(s.qtysold) AS total_tickets_vendidos
FROM event e
JOIN venue v ON e.venueid = v.venueid
JOIN sales s ON e.eventid = s.eventid
GROUP BY e.eventid, e.starttime, e.eventname, v.venuename, v.venuecity
ORDER BY total_tickets_vendidos DESC

git checkout mi-rama                          # Asegúrate de estar en tu rama
git add consultas_eventos.sql                 # Este es el que preguntas
git commit -m "Añadir consultas SQL del 18 al 21 sobre eventos y ventas"
git push origin mi-rama

