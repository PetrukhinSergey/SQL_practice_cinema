--ЗАДАНИЕ №1
--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language (
language_id serial primary key,
language_name varchar (50) not null,
last_update timestamp not null default now(),
deleted int2 not null default 0 check(deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
INSERT INTO language (language_name)
select
	unnest (array
		['русский', 'украинский', 'польский', 'чешский', 'болгарский', 'хорватский', 'немецкий', 'нидерландский',
		'английский', 'норвежский', 'шведский', 'итальянский', 'испанский', 'португальский', 'французский', 'турецкий',
		'казахский', 'азербайджанский', 'финский', 'венгерский', 'эстонский'])

-- delete from "language" -- удаление всех данных с таблицы (удалял, пока разбирался)

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table nation (
nation_id serial primary key,
nation_name varchar (50) not null,
last_update timestamp not null default now(),
deleted int2 not null default 0 check(deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
INSERT INTO nation (nation_name)
	VALUES
		('славяне'), ('германцы'), ('романцы'), ('тюрки'), ('финно-угоры')
		
--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
country_id serial primary key,
country_name varchar (50) not null,
last_update timestamp not null default now(),
deleted int2 not null default 0 check(deleted in (0, 1))
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
INSERT INTO country (country_name)
select
	unnest (array
		['Россия', 'Украина', 'Польша', 'Чехия', 'Болгария', 'Хорватия', 'Австрия', 'Голландия', 'Англия', 'Шотландия', 'Норвегия', 'Швеция', 'Италия',
		'Испания', 'Португалия', 'Франция', 'Бразилия', 'Аргентина', 'Турция', 'Казахстан', 'Азербайджан', 'Финляндия', 'Венгрия', 'Эстония'])

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table language_nation (
PRIMARY KEY (language_id, nation_id) -- добавил первичный ключ по нужным столбцам
language_id int not null references language (language_id),
nation_id int not null references nation (nation_id),
last_update timestamp not null default now()
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into language_nation (language_id, nation_id)
	values
	(1, 1), (1, 4), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 2), (8, 2), (9, 2), (10, 2), (11, 2),
	(11, 5), (12, 3), (13, 3), (14, 3), (15, 3), (16, 4), (17, 4), (18, 4), (19, 5), (20, 5), (21, 5)


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table country_nation (
PRIMARY KEY (country_id, nation_id),
country_id int not null references country (country_id),
nation_id int not null references nation (nation_id),
last_update timestamp not null default now()
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into country_nation (country_id, nation_id)
	values
	(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 2), (8, 2), (9, 2), (10, 2), (11, 2), (12, 2),
	(13, 3), (14, 3), (15, 3), (16, 3), (17, 3), (18, 3), (19, 4), (20, 4), (21, 4), (22, 5), (23, 5), (24, 5)


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
create table film_new (
film_name varchar(255) not null,
film_year integer check (film_year > 0),
film_rental_rate numeric(4,2) default '0.99',
film_duration integer not null check (film_duration >0)
)

--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select
	unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']),
	unnest (array[1994, 1999, 1985, 1994, 1993]),
	unnest (array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest (array[142, 189, 116, 142, 195]
	)

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
UPDATE film_new 
  SET film_rental_rate = film_rental_rate + 1.41

--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new
delete from film_new
where film_name = 'Back to the Future'

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values
	('Cruel romance', 1984, 1.55, 137)

--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
	-- *** --
-- select film_name, round(film_duration/60,1)
-- from film_new fn 
	-- *** --
-- select film_name, cast((film_duration) as float4)/60
-- from film_new fn
	-- *** --
-- select film_name, round((cast((film_duration) as float4)/60),1)
-- from film_new fn
	-- *** --	
select film_name as "Наименование фильма", 
	round(cast((film_duration) as decimal (6,1))/60,1) as "Длительность фильма в часах"
from film_new fn

--ЗАДАНИЕ №7 
--Удалите таблицу film_new
drop table film_new cascade