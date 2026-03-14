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
