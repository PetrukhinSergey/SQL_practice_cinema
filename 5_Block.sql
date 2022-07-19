--1. Написать SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом "Behind the Scenes".

-- explain analyze -- 67.50 / 0.475
select film_id, title, special_features
from film
where special_features && array['Behind the Scenes']

--2. Написать еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes", используя другие функции или операторы языка SQL для поиска значения в массиве.

-- explain analyze -- 250 / 1.385
select film_id, title, array_agg(unnest)
from (
	select film_id, title, unnest(special_features)
	from film) t
where unnest = 'Behind the Scenes'
group by film_id, title

-- или
select film_id, title, special_features
from film
where special_features @> array['Behind the Scenes']

--3. Для каждого покупателя посчитать сколько он брал в аренду фильмов со специальным атрибутом "Behind the Scenes.
--Обязательное условие: использовать запрос из задания 1, --помещенный в CTE.

with ste as (
	select film_id, title, special_features
	from film
	where special_features && array['Behind the Scenes']
	)
select  distinct c.customer_id, 
	count (f.film_id) over (partition by c.customer_id) as film_count
from customer c
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
join ste on ste.film_id = f.film_id 
order by 1

--4. Для каждого покупателя посчитать сколько он брал в аренду фильмов со специальным атрибутом "Behind the Scenes".
--Обязательное условие: использовать запрос из задания 1, помещенный в подзапрос.

select distinct r.customer_id,
	count (t.film_id) over (partition by r.customer_id) as film_count
from (select film_id, title, special_features
	from film
	where special_features && array['Behind the Scenes']
	) t
join inventory i on t.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
order by 1 

-- 5. Вывеcти сколько раз встречается специальный атрибут (special_features) у фильма

select title, array_length(special_features, 1)
from film

-- 6. Вывеcти сколько элементов содержит атрибут special_features

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

-- 7. Вывести все фильмы содержащие специальные атрибуты: 'Trailers','Commentaries'
-- * Используйте операторы: @> - содержит; <@ - содержится в; *  ARRAY[элементы] - для описания массива

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features
from film
where special_features[1] = 'Trailers' or special_features[1] = 'Commentaries'
	or special_features[2] = 'Trailers' or special_features[2] = 'Commentaries'
	or special_features[3] = 'Trailers' or special_features[3] = 'Commentaries'
	or special_features[4] = 'Trailers' or special_features[4] = 'Commentaries'

-- или
select title, special_features
from film
where special_features::text like '%Trailers%' or special_features::text like '%Commentaries%'

-- или
select title, special_features
from film
where array_position(special_features, 'Trailers') > 0 or 
	array_position(special_features, 'Commentaries') > 0

-- ЧТО-ТО СРЕДНЕЕ --
select title, array_agg(unnest)
from (
	select film_id, title, unnest(special_features)
	from film) t
where unnest = 'Trailers' or unnest = 'Commentaries'
group by film_id, title

-- ХОРОШАЯ ПРАКТИКА --
select title, special_features
from film
where special_features && array['Trailers'] or special_features && array['Commentaries']

-- или
select title, special_features
from film
where special_features @> array['Trailers'] or special_features @> array['Commentaries']

--или
select title, special_features
from film
where array['Trailers'] <@ special_features or array['Commentaries'] <@ special_features

--или
select title, special_features
from film
where special_features <@ array['Trailers'] or special_features <@ array['Commentaries']

-- или
select title, special_features
from film
where 'Trailers' = any(special_features) or 'Commentaries' = any(special_features) 
	
--8. Создать материализованное представление с запросом из предыдущего задания и написать запрос для обновления материализованного представления

create materialized view demo_1 as 
	select distinct r.customer_id,
		count (t.film_id) over (partition by r.customer_id) as film_count
	from (select film_id, title, special_features
		from film
		where special_features && array['Behind the Scenes']
		) t
	join inventory i on t.film_id = i.film_id 
	join rental r on i.inventory_id = r.inventory_id
	order by 1

refresh materialized view demo_1

--9. Создать материализованное представление с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
-- Создать материализованное представление без наполнения (with NO DATA):

create materialized view task_3 as
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental r) -- возвращаем строки из rental с результатом row_number() в окне по customer_id
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
with no data

--10. Используя оконную функцию вывести для каждого сотрудника сведения о самой первой продаже этого сотрудника.

select t.staff_id, f.film_id, f.title, t.amount, t.payment_date, c.last_name, c.first_name
from (
	select p.staff_id, p.amount, p.payment_date, p.customer_id, p.rental_id,
	row_number () over (partition by staff_id order by payment_date)
	from payment p ) t 
join customer c on t.customer_id = c.customer_id
join rental r on t.rental_id = r.rental_id 
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id 
where row_number = 1


--11. Для каждого магазина определить и выведсти одним SQL-запросом следующие аналитические показатели:
-- * день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- * количество фильмов взятых в аренду в этот день
-- * день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- * сумму продажи в этот день

select t1.store_id as "ID магазина", rental_date as "Дата с наибольшей арендой в день", count as "Кол-во фильмов, в этот день", payment_date as "Дата с наименьшей суммой продажи", sum as "Сумма продажи" 
	from (
		select i.store_id, r.rental_date::date, count(i.film_id), 
			row_number() over (partition by i.store_id order by count(i.film_id) desc) as count_rental
		from rental r 
		join inventory i on i.inventory_id = r.inventory_id
		group by i.store_id, r.rental_date::date) t1
	join (
		select i.store_id, p.payment_date::date, sum(p.amount), 
			row_number() over (partition by i.store_id order by sum(p.amount)) as sum_payment
		from rental r 
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		group by i.store_id, p.payment_date::date) t2 
	on t1.store_id = t2.store_id
where count_rental = 1 and sum_payment = 1
