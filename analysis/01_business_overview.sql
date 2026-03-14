--1️⃣ What is the distribution of orders by operational status (revenue-valid, failure, in_progress) on the platform?
select * ,
	round((category_orders*100/total_orders),2) as percentage
from 
(
	select 
		category , 
		count(*) as category_orders ,
		sum(count(*))over() as total_orders 
	from 
	(
		select 
			case 
				when order_status = 'delivered' then 'valid_revenue'
				when order_status = 'cancelled' or order_status = 'unavailable' then 'failure'
			else 'in_progress' 
			end as category
		from orders
	) a 
	group by category
)b
; 

--2️⃣ what is the Total delivered revenue ,Total delivered orders ,AOV ? 
select * ,
	round((total_revenue/total_orders),2) aov
from 
(
	select 
		count(distinct o.order_id) as total_orders ,
		sum(oi.price) as total_revenue 
	from orders as o 
	join order_items as oi 
		on oi.order_id = o.order_id 
	where order_status = 'delivered'
) 
; 

--3️⃣ What is a per_month total_revenue and growth_rate ? 
with platform_calender as 
(
	select 
		generate_series
		(
		date_trunc('month',min(order_purchase_timestamp)),
		date_trunc('month',max(order_purchase_timestamp)),
		interval '1 month'
		) as all_months
	from orders 
),
monthly_revenue as 
(
select 
	date_trunc('month',o.order_purchase_timestamp) months,
	sum(oi.price) as month_revenue
from orders as o 
join order_items as oi 
	on oi.order_id = o.order_id 
where order_status = 'delivered'
group by date_trunc('month',o.order_purchase_timestamp)
) ,
current_month as 
(
	select 
		pc.all_months as months  , 
		lag(coalesce(mr.month_revenue , 0))over(order by all_months) as previous_revenue ,
		coalesce(mr.month_revenue , 0) as current_revenue
	from platform_calender as pc 
	left join monthly_revenue as mr 
		on pc.all_months = mr.months
) 
select *,
	current_revenue - previous_revenue as revenue_change, 
	round(((current_revenue - previous_revenue)/nullif(previous_revenue ,0))*100 ,2) as growth_rate 
from current_month
;

--4️⃣ all category total_orders , total_revenue and it's contribution 
select 
	product_category , 
	total_orders , 
	category_revenue , 
	round((category_revenue*100/total_revenue),3) as percentage 
from 
(
	select 
		coalesce(pt.product_category_name_english ,'unknown') as product_category ,
		sum(oi.price) as category_revenue,
		count(distinct(o.order_id)) as total_orders,
		sum(sum(oi.price))over() as total_revenue
	from products as p 
	left join product_category_name_translation as pt 
		on pt.product_category_name = p.product_category_name 
	join order_items as oi 
		on p.product_id = oi.product_id
	join orders as o 
	on o.order_id = oi.order_id 
	where o.order_status = 'delivered'
	group by 
		coalesce(pt.product_category_name_english ,'unknown')
) 
order by 
	category_revenue desc 
	; 


