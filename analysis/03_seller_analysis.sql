--1️⃣ which seller generate the most revenue also show there orders and aov 
select 
	s.seller_id ,
	sum(oi.price) as total_revenue , 
	count(distinct(o.order_id)) as total_orders ,
	round(sum(oi.price)/count(distinct(o.order_id)),2) as aov  
from order_items as oi 
right join sellers as s
	on s.seller_id = oi.seller_id
join orders as o 
	on o.order_id = oi.order_id 
group by s.seller_id 
order by total_revenue desc 
limit 10 ; 
