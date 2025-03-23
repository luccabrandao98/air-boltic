with customer_orders as (
    select
        customer_id
        , count(distinct trip_id) as total_trips
        , sum(price) as total_gmv_spent
    from {{ ref('src_order') }}
    where 
        status <> 'Cancelled'
    group by customer_id
)
select
    c.customer_id as id
    , c.name
    , trim(c.email) as email
    , c.phone_number
    , coalesce(co.total_trips, 0) as total_trips
    , coalesce(co.total_gmv_spent,0) as total_gmv_spent
    , c.customer_group_id
    , case 
        when c.customer_group_id is null then 'group unknown' 
        when c.customer_group_id is not null and cg.type is null then 'type not registered'
        else cg.type end as customer_group_type
    , case 
        when c.customer_group_id is null then 'group unknown' 
        when c.customer_group_id is not null and cg.name is null then 'name not registered'
        else cg.name end as customer_group_name
    , case 
        when c.customer_group_id is null then 'group unknown' 
        when c.customer_group_id is not null and cg.registry_number is null then 'registry number not registered'
        else cg.registry_number end as customer_group_registry_number
from {{ ref('src_customer') }} c
left join
    {{ ref('src_customer_group') }} cg on c.customer_group_id = cg.id
left join
    customer_orders co on c.customer_id = co.customer_id
order by c.customer_id