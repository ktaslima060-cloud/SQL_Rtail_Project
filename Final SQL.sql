---select
---*
---from "DimCustomers"
select
*
from public."DimCustomers"



select
"Gender",
"phone"
from public."DimCustomers"
limit 10


select
*
from public."DimProducts" 

select






---Condition 

select
*
from public."DimCustomers"
where "city" = 'Chattogram'


select
*
from public."DimCustomers"
where "Gender" = 'Male'

Select
*
from public."DimCustomers"
where "city" = 'Chattogram' OR "city" = 'Dhaka'


Select
*
from public."DimCustomers"


Select
*
from public."DimCustomers"
where "city" in ('Chattogram', 'Khulna', 'Rajshahi')



Select
*
from public."DimCustomers"
where "city" not in ('Chattogram', 'Khulna', 'Rajshahi')



Select
*
from public."DimCustomers"
where "email" ilike('%gmail%')

Select
*
from public."DimCustomers"
where "email" ilike('%gmail%')


Select
*
from public."DimCustomers"
where "phone" ilike('19%')
and "city" = 'Chattogram'


SELECT *
FROM public."DimCustomers"
WHERE "Gender" = 'Female'
  AND "city" IN ('Dhaka', 'Chattogram', 'Barishal')
  AND (
      "email" ILIKE '%gmail%'
      OR "email" ILIKE '%outlook%'
  



select
*
from public."DimCustomers"
limit 10
offset 0



select
*
from public."DimCustomers"


select
count("customer_id")
from public."DimCustomers"




select
count("customer_id") as "Total Customers"
from public."DimCustomers"

select 
*
from public."DimCustomers"


select 
"city",
count(*) as "Total Customers"
from public."DimCustomers"
group by "city"



select 
"city",
count(*) as "Total Customers"
from public."DimCustomers"
group by "city"
order by count("customer_id") 


select
"city",
count(*) as "Total Customers"
from public."DimCustomers"
group by 1
having count (*)>10
order by 2 desc

select 
*
from public."DimCustomers"
where "full_name" ilike('%l%')
and "full_name" not ilike('l%')
and "full_name" not ilike('%l')


select
*
from public."FactOrderItems" 

select
*
from public."FactOrders"


select
*
from public."FactPayment - FactPayment"


select
*,
case
	when "unit_price" >500 then 'High Price'
	when "unit_price" >200 then 'Medium Price'
	else 'Low Price'
end as "Pricing Category"
from public."DimProducts"


select 
"city",
count(case when "Gender"='Male' then "customer_id"  else null end)as "Male",
count(case when "Gender"='Female' then "customer_id" else null end)as "Female"
from public."DimCustomers"
group by 1
select avg("unit_price") from public."DimProducts" 

select
*,
case
	when "unit_price" > (select avg("unit_price") from public."DimProducts") then 'Above Avg'
		else 'Low Avg'
end as "Product"


with order_based as(
select
"order_date"::date as "Order Date",
o."order_id" as "Order Id",
"full_name" as "Customer Name",
count(distinct oi."product_id") as "Total SKU",
sum("unit_price"*"quantity") as "Order Value",
sum("quantity") as "Total quantity",
"method" as "Payment method"
from public."FactOrders" as o
left join public."DimCustomers" c on o."customer_id"= c."customer_id"
left join public."FactOrderItems" oi on oi."order_id"=o."order_id"
left join public."DimProducts" p on p."product_id"=oi."product_id"
left join public."FactPayment - FactPayment" pay on o."order_id"= pay."order_id"
group by 1,2,3,7
order by 1 asc,2 asc





with order_base as (
	select
		"order_date"::date as "Order Date",
		o."order_id" as "Order Id",
		"full_name" as "Customer Name",
		c."customer_id",
		count(distinct oi."product_id") as "Total SKU",
		sum("unit_price"*"quantity") as "Order Value",
		sum("quantity") as "Total Quantity",
		"method" as "Payment Method"
	from public."FactOrders" as o
	left join public."DimCustomers" c on o."customer_id" = c."customer_id"
	left join public."FactOrderItems" oi on oi."order_id" = o."order_id"
	left join public."DimProducts" p on p."product_id" = oi."product_id"
	left join public."FactPayment - FactPayment" pay on o."order_id" = pay."order_id"
	group by 1,2,3,4,8
	order by 1, 2
)
select
"Order Date",
"Customer Name",
count(distinct "Order Id") as "Total Orders",
sum("Order Value") as "Total Order Value",
round(sum("Order Value")::numeric/count(distinct "Order Id"),2) as "AOV",
round(avg("Order Value"),2) as "AOV (avg function)"
from order_base
group by 1, "customer_id", 2
order by 1


-- cohort Analysis
with september_order as (
select
distinct "customer_id"
from public."FactOrders"
where "order_date":: date between '2025-09-01' and '2025-09-30'
),

december_order as (
select
distinct "customer_id"
from public."FactOrders"
where "order_date":: date between '2025-12-01' and '2025-12-30'
)
select
dec."customer_id"
from december_order dec
join september_order spt on dec."customer_id" = spt."customer_id"


-- cohort churn analysis find the customer who orderd in september but didn't in december 


with september_order as (
select
distinct "customer_id"
from public."FactOrders"
where "order_date":: date between '2025-09-01' and '2025-09-30'
),

december_order as (
select
distinct "customer_id"
from public."FactOrders"
where "order_date":: date between '2025-12-01' and '2025-12-30'
)
select
spt."customer_id" as "September Customers",
dec."customer_id" as "December Customers"
from september_order spt
left join december_order dec on spt."customer_id" = dec."customer_id"
where dec."customer_id" is null


-- product affinity analysis (self-join) 

select
*
from public."FactOrderItems"
select
oi1."order_id",
oi1."product_id" as "product1",
oi2."product_id" as "product2"
from public."FactOrderItems" oi1
left join public."FactOrderItems" oi2
on (oi1."order_id" = oi2."order_id" and oi1."product_id" < oi2."product_id")
where oi2."product_id" is not null



select
    concat(oi1."product_id", ' , ', oi2."product_id") as "Product Pair",
    count(oi1."order_id") as "Total Ordered"
from public."FactOrderItems" oi1
left join public."FactOrderItems" oi2
    on (oi1."order_id" = oi2."order_id" and oi1."product_id" <> oi2."product_id")
where oi2."product_id" is not null
group by 1
order by 2 desc


select
concat(p1."product_name",' , ',p2."product_name") "Product Combo",
count(distinct oi1."order_id") as "Total Orders"
from public."FactOrderItems" oi1
left join public."FactOrderItems" oi2 on (oi1."order_id" = oi2."order_id"
and oi1."product_id" < oi2."product_id")
left join public."DimProducts" p1 on oi1."product_id" = p1."product_id"
left join public."DimProducts" p2 on oi2."product_id" = p2."product_id"
where oi1."product_id" is not null and oi2."product_id" is not null
group by 1
order by 2 desc
limit 10