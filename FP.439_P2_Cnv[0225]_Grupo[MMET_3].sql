-- PLANTILLA DE ENTREGA DE LA PARTE PRÁCTICA DE LAS ACTIVIDADES
-- --------------------------------------------------------------
-- Actividad: AAn(P2)
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

-- Resolver con Combinaciones Externas

-- Pregunta 2.14 Crear una nueva tabla usuarios sin compras que deberá guardar aquellos usuarios que no han comprado ningún ticket con los campos userid, firstname, lastname, phone.
-- Pregunta 2.15 Crear una nueva tabla usuarios sin ventas que deberá guardar aquellos usuarios que no han vendido ningún ticket con los campos userid, firstname, lastname, phone.
-- Pregunta 2.16 Mostrar una lista con todos los usuarios que no se encuentren en la tabla listing con los campos userid, firstname, lastname, phone.
-- Pregunta 2.17 Mostrar aquellas fechas en las cuales no ha habido ningún evento. Se deberá mostrar los campos caldate y holiday

-- Resolver con Subconsultas

-- Pregunta 2.18 Mostrar la cantidad de tickets vendidos y sin vender para las diferentes categorías de eventos.
-- Pregunta 2.19 Crea una consulta que calcule el precio promedio pagado por venta y la compare con el precio promedio por venta por trimestre. La consulta deberá mostrar tres campos: trimestre, precio_promedio_por_trimestre, precio_promedio_total
-- Pregunta 2.20 Muestra el total de tickets de entradas compradas de Shows y Conciertos.
-- Pregunta 2.21 Muestra el id, fecha, nombre del evento y localización del evento que más entradas ha vendido.

-- Resolver con Vistas

-- Pregunta 2.22 Crea una vista con los eventos del mes de la tabla que coincida con el mes actual. Grabar la vista con el nombre Eventos del mes
create view EventosDelMes AS select * from event where MONTH(starttime) = MONTH(CURDATE());
-- Se selecciona el mes de cada entrada y se filtra para que ese mes sea igual al mes en el que se lanza la consulta

-- Pregunta 2.23 Crear una vista que muestre las ventas por trimestre y grupo de eventos. Guardar con el nombre Estadisticas
CREATE VIEW Estadisticas as 
select 
CONCAT('Q', QUARTER(s.saletime)) as Trimestre, 
e.eventname, 
SUM(qtysold) as CantidadVendida,
SUM(pricepaid) as PrecioTotal
from sales s
inner join event e on s.eventid = e.eventid
group by 
CONCAT('Q', QUARTER(s.saletime)), 
e.eventname;
-- Se obtiene el trimestre mediante el metodo QUARTER sobre la columna "saletime", se obtiene el nombre del evento y sumatorio de cantidades e importes agrupando por trimestre y evento

-- Resolver con Consultas de UNION

-- Pregunta 2.24 Crear una consulta de UNION producto de las tablas usuarios sin compras y usuarios sin ventas:
-- Pregunta 2.25 Crear una consulta de UNION que en forma de tabla las columnas mes, año, 'ventas' as concepto, totalventas y a continuación mes, año, 'comisiones' as concepto, totalcomisiones. Guardarla en forma de vista con el nombre operaciones
