with aeroplane_details as (
	select
		a.airplane_id as id
		, a.airplane_model as aeroplane_model
		, a.manufacturer
		, am.engine_type
		, am.max_seats
		, am.max_distance as max_distance_km
		, am.max_weight as max_weight_kg
		, case
			when am.max_seats between 1 and 50 then 5500
			when am.max_seats between 51 and 100 then 12500
			when am.max_seats between 101 and 150 then 19500
			when am.max_seats between 151 and 200 then 35000
			when am.max_seats between 201 and 300 then 63000
		end as max_fuel_weight_kg
		, case
			when am.max_seats between 1 and 50 then 450
			when am.max_seats between 51 and 100 then 600
			when am.max_seats between 101 and 150 then 700
			when am.max_seats between 151 and 200 then 800
			when am.max_seats between 201 and 300 then 1000
		end as max_onboard_team_weight_kg
	from  {{ ref('src_aeroplane') }}  a
	left join
		{{ ref('src_aeroplane_model') }} am on a.airplane_model = am.model
)

select
	* 
	, max_weight_kg - max_fuel_weight_kg - max_onboard_team_weight_kg - 100*max_seats as max_baggage_weight_kg
	, (max_weight_kg - max_fuel_weight_kg - max_onboard_team_weight_kg - 100*max_seats)::float/max_seats as max_baggage_weight_per_seat_kg
from aeroplane_details