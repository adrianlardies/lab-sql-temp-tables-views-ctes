USE sakila;

-- 1. Crear una vista que resuma la información de los alquileres para cada cliente. La vista debe incluir el ID del cliente, el nombre, el correo electrónico y el número total de alquileres.
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;

-- 2. Crear una tabla temporal que calcule el total pagado por cada cliente. Utilizamos la vista anterior y la unimos con la tabla de pagos.
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    r.customer_id,
    SUM(p.amount) AS total_paid
FROM 
    customer_rental_summary r
JOIN 
    payment p ON r.customer_id = p.customer_id
GROUP BY 
    r.customer_id;

-- 3. Crear una CTE que una la vista del resumen de alquileres con la tabla temporal del resumen de pagos. Luego, generamos la consulta final.
WITH customer_summary AS (
    SELECT 
        r.customer_name,
        r.email,
        r.rental_count,
        p.total_paid,
        (p.total_paid / r.rental_count) AS average_payment_per_rental
    FROM 
        customer_rental_summary r
    JOIN 
        customer_payment_summary p ON r.customer_id = p.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(average_payment_per_rental, 2) AS average_payment_per_rental
FROM 
    customer_summary
ORDER BY 
    customer_name;