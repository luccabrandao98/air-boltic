with orders_per_trip as (
    select
        trip_id
        , count(order_id) as total_orders
    from {{ ref('src_order') }}
    where
        status <> 'Cancelled'
    group by trip_id
),

trip_transformations as (
    select
        t.trip_id as id
        , t.airplane_id as aeroplane_id
        , t.origin_city
        , t.destination_city
        , case 
            when t.start_timestamp > t.end_timestamp then t.end_timestamp
            else t.start_timestamp end as trip_start 
        , case
            when t.end_timestamp < t.start_timestamp then t.start_timestamp
            else t.end_timestamp end as trip_end
        , abs((extract('epoch' from t.end_timestamp) - extract('epoch' from t.start_timestamp))/60) as trip_duration_minutes
        , coalesce(total_orders,0)::float/am.max_seats as seat_utilization_rate
    from {{ ref('src_trip') }} as t
    left join
        {{ ref('src_aeroplane') }} a on t.airplane_id = a.airplane_id
    left join
        {{ ref('src_aeroplane_model') }} am on a.airplane_model = am.model
    left join
        orders_per_trip ot on t.trip_id = ot.trip_id
)
select
    * 
    , (date_trunc('week', trip_start + '1 day'::interval)::date - '1 day'::interval)::date as trip_start_week -- to get sunday
    , date_trunc('month', trip_start)::date as trip_start_month
    , (date_trunc('week', trip_end + '1 day'::interval)::date - '1 day'::interval)::date as trip_end_week
    , date_trunc('month', trip_end)::date as trip_end_month
from trip_transformations
order by id