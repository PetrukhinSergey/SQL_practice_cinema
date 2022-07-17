--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select c.first_name ||' '|| c.last_name as "Имя покупателя", a.address as "Адрес", c2.city as "Город", c3.country as "Страна"
from customer c 
left join address a on c.address_id = a.address_id
left join city c2 on a.city_id = c2.city_id 
left join country c3 on c2.country_id = c3.country_id

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select s.store_id as "ID магазина" , count(c.first_name) as "Кол-во покупателей"
from store s 
join customer c on s.store_id = c.store_id 
group by 1

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select s.store_id as "ID магазина" 
, count(c.first_name) as "Кол-во покупателей"
from store s 
join customer c on s.store_id = c.store_id 
group by 1
having count(c.first_name) > 300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select s.store_id as "ID магазина" 
, count(c.first_name) as "Кол-во покупателей"
, c2.city as "Город"
, s2.first_name ||' '|| s2.last_name as "Имя сотрудника"
from store s 
join customer c on s.store_id = c.store_id 
join address a on s.address_id = a.address_id
join city c2 on a.city_id = c2.city_id
join staff s2 on s.store_id = s2.store_id
group by ("ID магазина", "Город", "Имя сотрудника")
having count(c.first_name) > 300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select c.first_name ||' '|| c.last_name as "Покупатель"
, count(r.rental_date ) as "Кол-во фильмов"
from customer c
join rental r on c.customer_id = r.customer_id 
group by 1
order by 2 desc 
limit (5)

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select c.first_name ||' '|| c.last_name as "Покупатель"
, count(r.rental_date ) as "Кол-во фильмов"
, ROUND(sum(p.amount ),0) as "Общая стоимость платежей"
, min(p.amount) as "Минимальная стоимость платежа"
, max(p.amount) as "Максимальная стоимость платежа"
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on p.rental_id = r.rental_id
group by 1

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

 select c.city as "Город 1"
, c2.city as "Город 2"
 from city c, city c2
 where c.city <> c2.city 
 
--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.

 select customer_id as "ID покупателя" 
, round(avg(return_date:: date - rental_date:: date),2) as "Среднее кол-во дней на возврат"
 from rental r 
 group by 1
 order by 1

--ЗАДАНИЕ №7
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f.title as "Название фильма"
, f.rating as "Рейтинг"
, c."name" as "Жанр"
, f.release_year as "Год выпуска"
, l."name" as "Язык"
, count(i.film_id) as "Кол-во аренд"
, sum(p.amount) as "Общая ст-ть аренды"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
join "language" l on f.language_id = l.language_id 
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
left join payment p on r.rental_id = p.rental_id
group by 1,2,3,4,5
order by 1

--ЗАДАНИЕ №8
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select f.title as "Название фильма"
, f.rating as "Рейтинг"
, c."name" as "Жанр"
, f.release_year as "Год выпуска"
, l."name" as "Язык"
, count(i.film_id) as "Кол-во аренд"
, sum(p.amount) as "Общая ст-ть аренды"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
join "language" l on f.language_id = l.language_id 
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
left join payment p on r.rental_id = p.rental_id 
group by 1,2,3,4,5 
having count(i.film_id) = 0
order by 1

--ЗАДАНИЕ №9
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select staff_id, count(payment_id) as "Количество продаж"
, 	case
		when count(payment_id) > 7300 then 'Да'
		else 'Нет'
	end as "Премия"
from payment
group by staff_id







