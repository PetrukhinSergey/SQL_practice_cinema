-- 1. С помощью оконных функций добавить вычисляемые колонки согласно условиям:
--Пронумеровать все платежи от 1 до N по дате +
--Пронумеровать платежи для каждого покупателя, сортировка платежей должна быть по дате
--Рассчет нарастающим итогом суммы всех платежей для каждого покупателя, сортировка должна сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Нумерация платежей для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.

select p.customer_id, p.payment_id,p.payment_date,
	row_number () over (order by p.payment_date) as "Num_payment_by_date", -- нумерация платежей по дате
	row_number () over (partition by p.customer_id order by p.payment_date) as "Num_payment_by_customer", -- нумерация платежей по покупателю
	sum(amount) over (partition by p.customer_id order by p.payment_date) as "Cumulative_total_sum", -- нарастающий итог всех платежей по покупателю
	dense_rank () over (partition by p.customer_id order by p.amount desc) as "Num_payment_by_amount" -- нумерация платежей от большего к меньшему
from payment p
order by p.payment_date:: date, "Cumulative_total_sum" desc

-- 2. С помощью оконной функции вывести для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
select customer_id, payment_id, payment_date, amount,
	lag (amount, 1, 0.) over(partition by customer_id order by payment_date) as last_amount -- указываем вместо null значение '0'
from payment p 
order by customer_id, payment_id, payment_date 

-- 3. С помощью оконной функции определить, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select customer_id, payment_id, payment_date, amount,
	amount - lead (amount, 1, 0.) over(partition by customer_id order by payment_date) as last_amount
from payment p
order by 1,2,3

-- 4. С помощью оконной функции для каждого покупателя вывести данные о его последней оплате аренды.

select customer_id, payment_id, payment_date, amount
from (
	select  customer_id, payment_id, payment_date, amount,
		row_number() over (partition by customer_id order by payment_date desc)
	from payment) t
where row_number = 1

-- 5. С помощью оконной функции вывести для каждого сотрудника сумму продаж за август 2005 года:
-- с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
-- с сортировкой пcustomer_id, payment_date, amount,

select staff_id, payment_date::date, sum (amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment
where date_trunc ('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

--6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
-- С помощью оконной функции вывести всех покупателей, которые в день проведения акции получили скидку

with p1 as (
	select customer_id, payment_date,
		row_number () over (order by payment_date) N
	from payment p 
	where payment_date between '20.08.2005' and '21.08.2005' -- создал СТЕ по нужному периоду
)
select *
from p1
where N % 100 = 0 -- запрос на вывод каждой 100-ой строки

-- 7. Для каждой страны определить и вывести одним SQL-запросом покупателей, которые попадают под условия:
-- * покупатель, арендовавший наибольшее количество фильмов
-- * покупатель, арендовавший фильмов на самую большую сумму
-- * покупатель, который последним арендовал фильм

with c1 as (
	select c.first_name ||' '|| c.last_name  as full_name, c3.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
c2 as (
	select full_name, country_id,
		row_number () over (partition by country_id order by count desc) as count_film,
		row_number () over (partition by country_id order by sum desc) as sum_amount,
		row_number () over (partition by country_id order by max desc) as last_date
	from c1
)
select c.country, c_1.full_name as "Арендовал больше всех фильмов", c_2.full_name as "Сумма аренды больше всех", c_3.full_name as "Последний арендовал фильм"
from country c
join c2 c_1 on c_1.country_id = c.country_id and c_1.count_film = 1
join c2 c_2 on c_2.country_id = c.country_id and c_2.sum_amount = 1
join c2 c_3 on c_3.country_id = c.country_id and c_3.last_date = 1
order by 1


