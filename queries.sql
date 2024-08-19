1)Retrieve the total number of orders placed?
	select count(order_details_id) as total_orders from order_details;

2)Calculate the total revenue generated from pizza sales?
select sum(order_details.quantity*pizza.price) as total_revenue from order_details join pizza on order_details.pizza_id=pizza.pizza_id;	

3)Identify the highest-priced pizza?
select pizza.price as highest_priced_pizza,pizza_types.nam from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id
	order by pizza.price desc limit 1;
4) Identify the most common pizza size ordered?
select pizza.size,count(order_details.order_details_id) as co from pizza join order_details on pizza.pizza_id=order_details.pizza_id
	group by pizza.size;

5) list the top 5 most ordered pizza types along with their quantities?
select pizza_types.nam,sum(order_details.quantity) as ads from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	group by pizza_types.nam 
	order by ads desc limit 5; 

6) join the necessary tables to find the total quantity of each pizza category ordered?
select pizza_types.category,sum(order_details.quantity) as quantity from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
group by pizza_types.category order by quantity desc; 

7) Determine the distribution of orders by hour of the day?
SELECT 
    EXTRACT(HOUR FROM tim) AS hour_of_day,
    COUNT(*) AS order_count
FROM 
    "order"
GROUP BY 
    hour_of_day
ORDER BY 
    hour_of_day;

8) Group the orders by date and calculate the average number of pizzas ordered per day?
select round(avg(total_quantity),0) as avg_pizzas from (select "order".dat, sum(order_details.quantity) as total_quantity from "order" join order_details on "order".order_id=order_details.order_id
group by "order".dat
	order by "order".dat);

9) Join relevant tables to find category-wise pizza distribution?
select category , count(nam) as pizza_name from pizza_types group by category;

10)Determine the top 3 most ordered pizza types based on revenue?
select pizza_types.nam as pizza_name,round(cast(SUM(order_details.quantity * pizza.price) as numeric),2)  as revenue from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	group by pizza_types.nam
	order by revenue desc limit 3;

11) calculate the percentage contribution of each pizza type to total revenue?
select pizza_types.nam as pizza_name, ROUND(
        CAST(SUM(order_details.quantity * pizza.price) / 
        (SELECT SUM(order_details.quantity * pizza.price) FROM order_details JOIN pizza ON order_details.pizza_id = pizza.pizza_id) * 100 AS numeric), 2
    ) AS pizza_type_contri
from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	group by pizza_types.nam;

/*select pizza_types.nam as pizza_name,sum(order_details.quantity*pizza.price) as total from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	group by pizza_types.nam; 

select sum(order_details.quantity*pizza.price) as total_revenue from order_details join pizza on order_details.pizza_id=pizza.pizza_id;*/

12) Analyse the cumulative revenue generated over time?
with cte as(
select "order".dat as dat,round(cast(sum(order_details.quantity*pizza.price) as numeric),2) as total from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	join "order" on "order".order_id=order_details.order_id
	group by "order".dat
	order by "order".dat)
SELECT 
    cte.dat AS dat, 
    SUM(cte.total) OVER (ORDER BY cte.dat ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumm_revenue
FROM 
    cte
ORDER BY 
    cte.dat;

13)Determine the top 3 most ordered pizza types based on revenue for each category?
select * from(select pizza_name,pizza_category,total_revenue,row_number() over(partition by pizza_category order by total_revenue desc) as rn from (select pizza_types.nam as pizza_name, pizza_types.category as pizza_category,sum(order_details.quantity*pizza.price) as total_revenue
from pizza_types join pizza on pizza_types.pizza_type_id=pizza.pizza_type_id join order_details on order_details.pizza_id=pizza.pizza_id
	group by pizza_types.nam,pizza_types.category
	order by pizza_types.category)as a)as b where rn<=3;
