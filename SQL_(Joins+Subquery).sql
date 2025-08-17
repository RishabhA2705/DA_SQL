use mavenmovies;

select first_name , last_name , amount from customer c left join payment p on c.customer_id = p.customer_id;
select * from film;
select title, count(rental_id) as rental_times from film f left join inventory i on f.film_id = i.film_id left join rental r on r.inventory_id = i.inventory_id
group by title having count(rental_id) < 1; 

select s.staff_id, concat(first_name," ", last_name) as name , count(py.payment_id) as total_payments from staff s 
left join payment py on s.staff_id = py.staff_id group by s.staff_id , s.first_name , s.last_name;

select s.store_id , count(f.film_id) as film_count from film f left join inventory i on f.film_id = i.film_id 
left join store s on s.store_id = i.store_id group by s.store_id order by film_count ;

select c.name , count(fc.film_id) as total_movie_count from category c 
left join film_category fc on fc.category_id = c.category_id group by c.name;

select * from film cross join film_category;
SELECT f1.title AS film1, f2.title AS film2
FROM film f1 JOIN film f2 ON f1.length = f2.length AND f1.film_id < f2.film_id
ORDER BY f1.length;

select * from customer natural join payment;
select * from category natural join film_category;

#Use a CROSS JOIN to list all possible combinations of staff members and store IDs.
select * from staff cross join store ;

#Use a NATURAL JOIN to display all film rental information with matching customer details.
select * from customer natural join rental;
#Create a SELF JOIN query to find pairs of customers from the same city.

#Using USING, join film, film_category, and category to list all films and their categories.
select f.title , c.name from category c left join film_category fc using(category_id) left join film f using(film_id) ;

#Find all categories that have no films assigned
select * from film_category;
select c.name from category c left join film_category fc using(category_id) where film_id is null; 
	
#List all customers who have at least one rental.
select cu.first_name from customer cu left join rental r using(customer_id) where rental_id >=1;

#Use a SELF JOIN to find actors who share the same last name.
select a1.actor_id ,a1.first_name , a1.last_name , 
a2.actor_id, a2.first_name , a2.last_name from actor a1 join actor a2 on a1.last_name = a2.last_name and a1.actor_id < a2.actor_id; 

#Create a CROSS JOIN between category and rating (from film) to find missing combinations.
select rating from category cross join film;

#Show each store’s ID, the month of payment, and the total revenue for that month.
#Only include months where the total revenue is greater than 10,000
select s.store_id , date_format(p.payment_date,'%Y-%m') as month, sum(p.amount) as total_revenue from store s 
join staff using (store_id) join payment p using (staff_id) GROUP BY s.store_id, DATE_FORMAT(p.payment_date, '%Y-%m')
HAVING SUM(p.amount) > 10000
ORDER BY s.store_id, month;

#For each film category, list each film title and the number of times it has been rented.
#Only show films that have been rented at least 50 times.

select name , title , count(rental_id) from category c join film_category fc on fc.category_id = c.category_id 
join film f on f.film_id = fc.film_id  join inventory i on i.film_id = f.film_id join rental using (inventory_id) 
group by name , title having count(rental_id) >= 50 ;

# give me payments which are above avg.
select * from payment where amount > (select avg(amount) from payment) order by amount; 

#Find all films longer than the average film length.
select title , length as film_length from film where length > (select avg(length) from film);
select avg(length) from film;

#List customers who have made payments greater than $10.
select customer_id , concat(first_name , ' ' , last_name) as full_name from customer 
where customer_id in (select distinct customer_id from payment where amount > 10);

#Show actors who acted in the longest film.
select distinct actor_id , concat(first_name , ' ' , last_name) as full_name from actor a 
join film_actor fa using (actor_id) join film f using (film_id) where f.length = (select max(length) from film);

#Get all films with rental rates above the average rental rate.
select film_id , title , rental_rate from film where rental_rate > (select avg(rental_rate) from film); 

#Find categories whose average film length is greater than 120 minutes.
select c.name , avg(f.length) from ( select c.name , length  from category c join film_category using (category_id) 
join film using (film_id) ) as cat_avg where length > 120 order by length ;

#List the top 5 longest films by length.
select title , length from film order by length desc limit 5;

#Show rentals made after the latest payment date.
select rental_id , rental_date from rental where rental_date > ( select MAX(payment_date) from payment);

#Find categories that have no films assigned.
Select c.name from category c where category_id NOT IN (select distinct category_id from film_category); 

#List customers whose total spending is greater than 100.
select customer_id , first_name from customer where customer_id in
(select customer_id from payment group by customer_id having sum(amount) > 100);

# Correlated Subquery
SELECT p1.customer_id, p1.amount FROM payment p1
WHERE p1.amount > (SELECT AVG(p2.amount) FROM payment p2 WHERE p2.customer_id = p1.customer_id);

#Find customers who have rented more than 20 films.
select c.first_name  from customer c where ( select sum(customer_id) from rental r where r.customer_id = c.customer_id) > 20;

#List films whose rental rate is higher than the average rental rate of films in the same category.
select title , rental_rate , name from film f join film_category fc using (film_id) join category c using (category_id) 
where f.rental_rate > (select avg(rental_rate) from film f2 join film_category fc2 using (film_id) where fc.category_id = fc2.category_id) order by rental_rate;

#Find actors who acted in more than 10 films.
select a.actor_id , a.first_name from actor a  
where ( select count(film_id) from film_actor fa where fa.actor_id = a.actor_id) > 10;

#Show customers whose total payments are more than $150.
select cu.customer_id , cu.first_name from customer cu where ( select sum(amount) from payment p where p.customer_id = cu.customer_id) > 150; 

#Find customers who have never rented a film.
select c.customer_id , c.first_name from customer c where not exists ( select 1 from rental r where r.customer_id = c.customer_id);

#List films that have been rented more times than film_id = 5.
select f.title from film f
