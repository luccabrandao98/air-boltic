select
    o.order_id as id
    , o.customer_id
    , o.trip_id
    , t.airplane_id as aeroplane_id
    , o.seat_no
    , case 
		when regexp_replace(o.seat_no, '[^A-Za-z]', '', 'g') in ('A', 'F') then 'window'
		when regexp_replace(o.seat_no, '[^A-Za-z]', '', 'g') in ('B', 'E') then 'middle'
		when regexp_replace(o.seat_no, '[^A-Za-z]', '', 'g') in ('C', 'D') then 'aisle'
	else null end as seat_type
    , o.status
    , o.price as gmv
    , sum(o.price) over(partition by o.customer_id order by o.order_id) as cumulative_gmv_customer
	, sum(case when status <> 'Cancelled' then o.price else 0 end) over(partition by o.customer_id order by o.order_id) as cumulative_not_canceled_gmv_customer
	, count(o.order_id) over(partition by o.customer_id order by o.order_id) as cumulative_order_count_customer
	, count(case when status <> 'Cancelled' then o.order_id else null end) over(partition by o.customer_id order by o.order_id) as cumulative_not_canceled_order_count_customer
from {{ ref('src_order') }} o
left join
    {{ ref('src_trip') }} t on o.trip_id = t.trip_id
order by o.order_id