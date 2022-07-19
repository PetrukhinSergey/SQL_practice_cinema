--1. Рассчитать совокупный доход всех магазинов на каждую дату.
select 
	s2.store_id,
	p.payment_date ::date paydate,
	sum(p.amount) || ' RUB' as "Совокупный доход"
from payment p
join staff s ON s.staff_id = p.staff_id 
join store s2 on s2.store_id = s.store_id
group by 1, 2
order by 1, 2;

--2. Вывести наиболее и наименее востребованные жанры
--(те, которые арендовали наибольшее/наименьшее количество раз),
--число их общих продаж и сумму дохода/

with count_by_category as(
	select 
		c.name,
		count(r.rental_id),
		sum(p.amount)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film_category fc on fc.film_id = i.film_id 
	join category c on c.category_id = fc.category_id 
	join payment p on p.rental_id = r.rental_id 
	group by 1
)
(select 'max' "rate", cbc.name as "Жанр", cbc.count as "Кол-во продаж", cbc.sum as "Сумма дохода"
from count_by_category cbc
order by cbc.count desc limit 1)
union 
(select 'min'"rate", cbc.name as "Жанр", cbc.count as "Кол-во продаж", cbc.sum as "Сумма дохода"
from count_by_category cbc
order by cbc.count limit 1)


--3. Какова средняя арендная ставка для каждого жанра?
--(упорядочить по убыванию)
select 
	c."name",
	round(avg(f.rental_rate), 2) avg_rate
from category c 
join film_category fc on fc.category_id = c.category_id 
join film f on f.film_id = fc.film_id 
group by c.category_id 
order by avg_rate desc

--4. Составить список из 5 самых дорогих клиентов (арендовавших фильмы с 22 по 23 августа).
--формат списка:
--'Имя_клиента Фамилия_клиента email address is: e-mail_клиента'
select 
	c.first_name ||' '|| c.last_name || ' email addres is: '|| c.email,
	sum(p.amount) 
from rental r 
join customer c on r.customer_id = c.customer_id 
join payment p on r.rental_id = p.rental_id 
where p.payment_date between '2005-08-22 0:0:0' and '2005-08-23 23:59:59'
group by c.customer_id 
order by 2 desc limit 5

--5. Сколько арендованных фильмов было возвращено в срок, до срока возврата и после, выведите максимальную разницу со сроком?

select 
	CASE
        WHEN f.rental_duration > date_part('day'::text, r.return_date - r.rental_date)::integer THEN 'Заранее'::text
        WHEN f.rental_duration = date_part('day'::text, r.return_date - r.rental_date)::integer THEN 'В срок'::text
        WHEN f.rental_duration < date_part('day'::text, r.return_date - r.rental_date)::integer THEN 'С опозданием'::text
        ELSE null::text
    END AS v,
	count(r.rental_id),
	max(@(date_part('day'::text, r.return_date - r.rental_date) - f.rental_duration))
from rental r 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
group by 1
having max(@(date_part('day'::text, r.return_date - r.rental_date) - f.rental_duration)) is not null