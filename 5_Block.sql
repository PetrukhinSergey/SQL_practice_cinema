--1. Íàïèñàòü SQL-çàïðîñ, êîòîðûé âûâîäèò âñþ èíôîðìàöèþ î ôèëüìàõ ñî ñïåöèàëüíûì àòðèáóòîì "Behind the Scenes".

-- explain analyze -- 67.50 / 0.475
select film_id, title, special_features
from film
where special_features && array['Behind the Scenes']

--2. Íàïèñàòü åùå 2 âàðèàíòà ïîèñêà ôèëüìîâ ñ àòðèáóòîì "Behind the Scenes", èñïîëüçóÿ äðóãèå ôóíêöèè èëè îïåðàòîðû ÿçûêà SQL äëÿ ïîèñêà çíà÷åíèÿ â ìàññèâå.

-- explain analyze -- 250 / 1.385
select film_id, title, array_agg(unnest)
from (
	select film_id, title, unnest(special_features)
	from film) t
where unnest = 'Behind the Scenes'
group by film_id, title

-- èëè
select film_id, title, special_features
from film
where special_features @> array['Behind the Scenes']

--3. Äëÿ êàæäîãî ïîêóïàòåëÿ ïîñ÷èòàòü ñêîëüêî îí áðàë â àðåíäó ôèëüìîâ ñî ñïåöèàëüíûì àòðèáóòîì "Behind the Scenes.
--Îáÿçàòåëüíîå óñëîâèå: èñïîëüçîâàòü çàïðîñ èç çàäàíèÿ 1, --ïîìåùåííûé â CTE.

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

--4. Äëÿ êàæäîãî ïîêóïàòåëÿ ïîñ÷èòàòü ñêîëüêî îí áðàë â àðåíäó ôèëüìîâ ñî ñïåöèàëüíûì àòðèáóòîì "Behind the Scenes".
--Îáÿçàòåëüíîå óñëîâèå: èñïîëüçîâàòü çàïðîñ èç çàäàíèÿ 1, ïîìåùåííûé â ïîäçàïðîñ.

select distinct r.customer_id,
	count (t.film_id) over (partition by r.customer_id) as film_count
from (select film_id, title, special_features
	from film
	where special_features && array['Behind the Scenes']
	) t
join inventory i on t.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id
order by 1 

-- 5. Âûâåcòè ñêîëüêî ðàç âñòðå÷àåòñÿ ñïåöèàëüíûé àòðèáóò (special_features) ó ôèëüìà

select title, array_length(special_features, 1)
from film

-- 6. Âûâåcòè ñêîëüêî ýëåìåíòîâ ñîäåðæèò àòðèáóò special_features

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

-- 7. Âûâåñòè âñå ôèëüìû ñîäåðæàùèå ñïåöèàëüíûå àòðèáóòû: 'Trailers','Commentaries'
-- * Èñïîëüçóéòå îïåðàòîðû: @> - ñîäåðæèò; <@ - ñîäåðæèòñÿ â; *  ARRAY[ýëåìåíòû] - äëÿ îïèñàíèÿ ìàññèâà

-- ÏËÎÕÀß ÏÐÀÊÒÈÊÀ --
select title, special_features
from film
where special_features[1] = 'Trailers' or special_features[1] = 'Commentaries'
	or special_features[2] = 'Trailers' or special_features[2] = 'Commentaries'
	or special_features[3] = 'Trailers' or special_features[3] = 'Commentaries'
	or special_features[4] = 'Trailers' or special_features[4] = 'Commentaries'

-- èëè
select title, special_features
from film
where special_features::text like '%Trailers%' or special_features::text like '%Commentaries%'

-- èëè
select title, special_features
from film
where array_position(special_features, 'Trailers') > 0 or 
	array_position(special_features, 'Commentaries') > 0

-- ×ÒÎ-ÒÎ ÑÐÅÄÍÅÅ --
select title, array_agg(unnest)
from (
	select film_id, title, unnest(special_features)
	from film) t
where unnest = 'Trailers' or unnest = 'Commentaries'
group by film_id, title

-- ÕÎÐÎØÀß ÏÐÀÊÒÈÊÀ --
select title, special_features
from film
where special_features && array['Trailers'] or special_features && array['Commentaries']

-- èëè
select title, special_features
from film
where special_features @> array['Trailers'] or special_features @> array['Commentaries']

--èëè
select title, special_features
from film
where array['Trailers'] <@ special_features or array['Commentaries'] <@ special_features

--èëè
select title, special_features
from film
where special_features <@ array['Trailers'] or special_features <@ array['Commentaries']

-- èëè
select title, special_features
from film
where 'Trailers' = any(special_features) or 'Commentaries' = any(special_features) 
	
--8. Ñîçäàòü ìàòåðèàëèçîâàííîå ïðåäñòàâëåíèå ñ çàïðîñîì èç ïðåäûäóùåãî çàäàíèÿ è íàïèñàòü çàïðîñ äëÿ îáíîâëåíèÿ ìàòåðèàëèçîâàííîãî ïðåäñòàâëåíèÿ

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

--9. Ñîçäàòü ìàòåðèàëèçîâàííîå ïðåäñòàâëåíèå ñ êîëîíêàìè êëèåíò (ÔÈÎ; email) è title ôèëüìà, êîòîðûé îí áðàë â ïðîêàò ïîñëåäíèì
-- Ñîçäàòü ìàòåðèàëèçîâàííîå ïðåäñòàâëåíèå áåç íàïîëíåíèÿ (with NO DATA):

create materialized view task_3 as
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental r) -- âîçâðàùàåì ñòðîêè èç rental ñ ðåçóëüòàòîì row_number() â îêíå ïî customer_id
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
with no data

--10. Èñïîëüçóÿ îêîííóþ ôóíêöèþ âûâåñòè äëÿ êàæäîãî ñîòðóäíèêà ñâåäåíèÿ î ñàìîé ïåðâîé ïðîäàæå ýòîãî ñîòðóäíèêà.

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


--11. Äëÿ êàæäîãî ìàãàçèíà îïðåäåëèòü è âûâåäñòè îäíèì SQL-çàïðîñîì ñëåäóþùèå àíàëèòè÷åñêèå ïîêàçàòåëè:
-- * äåíü, â êîòîðûé àðåíäîâàëè áîëüøå âñåãî ôèëüìîâ (äåíü â ôîðìàòå ãîä-ìåñÿö-äåíü)
-- * êîëè÷åñòâî ôèëüìîâ âçÿòûõ â àðåíäó â ýòîò äåíü
-- * äåíü, â êîòîðûé ïðîäàëè ôèëüìîâ íà íàèìåíüøóþ ñóììó (äåíü â ôîðìàòå ãîä-ìåñÿö-äåíü)
-- * ñóììó ïðîäàæè â ýòîò äåíü

select t1.store_id as "ID ìàãàçèíà", rental_date as "Äàòà ñ íàèáîëüøåé àðåíäîé â äåíü", count as "Êîë-âî ôèëüìîâ, â ýòîò äåíü", payment_date as "Äàòà ñ íàèìåíüøåé ñóììîé ïðîäàæè", sum as "Ñóììà ïðîäàæè" 
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
