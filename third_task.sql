--FIRST TASK

SELECT film_category.category_id as category, COUNT(film.film_id) AS film_count
FROM film_category
LEFT JOIN film ON film_category.film_id = film.film_id
GROUP BY category
ORDER BY film_count DESC;

-- SECOND TASK

SELECT actor.first_name, actor.last_name, actor_rental.rental
FROM actor
RIGHT JOIN (
    SELECT film_actor.actor_id AS actor, SUM(film.rental_duration) AS rental
    FROM film_actor
    LEFT JOIN film ON film_actor.film_id = film.film_id
    GROUP BY actor
    ORDER BY rental DESC
    LIMIT 10
) AS actor_rental ON actor_rental.actor = actor.actor_id
ORDER BY actor_rental.rental DESC;

-- THIRD TASK

SELECT category.name, cost_category.sum_cost
FROM category
LEFT JOIN (
    SELECT film_category.category_id, SUM(film.replacement_cost) AS sum_cost
    FROM film_category
    LEFT JOIN film ON film_category.film_id = film.film_id
    GROUP BY film_category.category_id
    ORDER BY sum_cost DESC
) AS cost_category ON cost_category.category_id = category.category_id
ORDER BY cost_category.sum_cost DESC
LIMIT 1;

-- FOURTH TASK

SELECT i.film_id AS inventory, f.film_id AS film
FROM inventory i
RIGHT JOIN film f ON i.film_id = f.film_id
WHERE i.film_id IS NULL;

-- FIFTH TASK

SELECT actor_id, films
FROM (
    SELECT film_actor.actor_id, COUNT(children_film.film_id) as films,
           RANK() OVER (ORDER BY COUNT(children_film.film_id) DESC) AS actor_rank
    FROM film_actor
    LEFT JOIN (
        SELECT f.film_id
        FROM film f
        LEFT JOIN (
            SELECT film_category.film_id
            FROM film_category
            LEFT JOIN category ON category.category_id = film_category.category_id
            WHERE category.name = 'Children'
        ) AS category_id ON category_id.film_id = f.film_id
    ) AS children_film ON children_film.film_id = film_actor.film_id
    GROUP BY film_actor.actor_id
) AS ranked_actors
WHERE actor_rank <= 3;

-- SIXTH TASK

SELECT 
    city.city, 
    cust_addr.active,
    cust_addr.inactive
FROM 
    city 
LEFT JOIN (
    SELECT 
        address.city_id, 
        cust_addr.active, 
        cust_addr.inactive 
    FROM 
        address 
    LEFT JOIN (
        SELECT 
            a.address_id, 
            SUM(CASE WHEN c.active != 1 THEN 1 ELSE 0 END) AS inactive, 
            SUM(CASE WHEN c.active = 1 THEN 1 ELSE 0 END) AS active 
        FROM 
            customer c 
        LEFT JOIN 
            address a ON a.address_id = c.address_id  
        GROUP BY 
            a.address_id
    ) AS cust_addr ON cust_addr.address_id = address.address_id
) AS cust_addr ON cust_addr.city_id = city.city_id 
ORDER BY 
    cust_addr.inactive;

-- SEVENTH TASK

SELECT 
    category,
    SUM(total_rent) AS sum_total_rent
FROM (
    SELECT 
        city,
        category,
        total_rent,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY total_rent DESC) AS rent_rank
    FROM (
        SELECT 
            ci.city AS city,
            cat.name AS category,
            SUM(f.rental_duration) AS total_rent
        FROM 
            customer c
        LEFT JOIN 
            address a ON a.address_id = c.address_id
        LEFT JOIN 
            city ci ON ci.city_id = a.city_id
        LEFT JOIN 
            rental r ON r.customer_id = c.customer_id
        LEFT JOIN 
            inventory i ON r.inventory_id = i.inventory_id
        LEFT JOIN 
            film f ON f.film_id = i.film_id
        LEFT JOIN 
            film_category fc ON f.film_id = fc.film_id
        LEFT JOIN 
            category cat ON cat.category_id = fc.category_id
        WHERE 
            ci.city LIKE 'a%' OR ci.city LIKE '%-%'
        GROUP BY 
            ci.city, cat.name
    ) AS ci_cat_rent
) AS subquery
WHERE 
    rent_rank = 1
GROUP BY 
    category
ORDER BY 
    sum_total_rent DESC
LIMIT 1;





