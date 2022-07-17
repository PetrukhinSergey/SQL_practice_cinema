<h2 align="center">Практическая отработка запросов SQL</a></h2>
В качестве источника информации была взята демонстрационная база данных по прокату DVD.  
Ниже представлена ER-диаграмма используемой базы
<div align="center"><img src="https://user-images.githubusercontent.com/108893866/179391999-2f8c6eaa-7ec0-4143-911e-1f8ba73d4b82.png" width="800" /></div><br>
Материалы будут разбиты на несколько блоков в зависимости от типов операций, на которые сделан акцент и сложности (по нарастающей).

<h3 align="center">Блок №1:</a></h3>

##### Цель: #####
* SELECT и названия колонкам;  
* фильтрация и сортировка строк в таблицах с использованием основных операторов языка SQL;  
* преобразование текстовых, числовых значений и дат с помощью функций языка SQL по работе со строками, датами и числам.
<details>
  <summary>:arrow_heading_down: Задачи: :eyes:</summary>
  
1. Выведите уникальные названия городов из таблицы городов.
2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.
4. Выведите информацию о 10-ти последних платежах за прокат фильмов.
5. Выведите следующую информацию по покупателям:
  + Фамилия и имя (в одной колонке через пробел)
  + Электронная почта
  + Длину значения поля email
  + Дату последнего обновления записи о покупателе (без времени)
  + Каждой колонке задайте наименование на русском языке.
6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.  
7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.  
8. Получите информацию о трёх фильмах с самым длинным описанием фильма.  
9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
  + в первой колонке должно быть значение, указанное до @,
  + во второй колонке должно быть значение, указанное после @.  
10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.
</details>

#### Cсылка на файл .sql со структурой запросов по Блоку №1
<div align="left"><a href="https://github.com/PetrukhinSergey/SQL_practice_cinema/blob/main/1_Block.sql" target="_blank">Запросы_Блок_1</a><img src="https://user-images.githubusercontent.com/108893866/179385582-25cdd117-2530-42e3-b7dc-1edd323f3e68.png" width="120" />
</div>

<h3 align="center">Блок №2:</a></h3>

##### Цель: #####
* функции агрегации и группировки строк;
* фильтрация по сгруппированным строкам;
* методы соединения таблиц с помощью разных вариаций JOIN.
<details>
  <summary>:arrow_heading_down: Задачи: :eyes:</summary>
  
1. Выведите для каждого покупателя его адрес, город и страну проживания.
2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. Ожидаемый результат запроса: letsdocode.ru.../3-2-2.png
Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. 
3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
4. Посчитайте для каждого покупателя 4 аналитических показателя:
 + количество взятых в аренду фильмов;
 + общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
 + минимальное значение платежа за аренду фильма;
 + максимальное значение платежа за аренду фильма.
5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.
6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.
7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
