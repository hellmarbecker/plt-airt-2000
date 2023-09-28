insert into `adsb-json-sr`
with cte2 as (
    with cte as (
        select
            key,
            decode(val, 'UTF-8') as strval
        from `adsb-raw`
    ) 
    select
        key,
        split_index(strval, ',',  6) || ' ' || split_index(strval, ',',  7) as `timestamp`,
        split_index(strval, ',',  0) as message_type,
        split_index(strval, ',',  1) as transmission_type,
        split_index(strval, ',',  2) as session_id,
        split_index(strval, ',',  3) as aircraft_id,
        split_index(strval, ',',  4) as hex_ident,
        split_index(strval, ',',  5) as flight_id,
        split_index(strval, ',',  6) as date_message_generated,
        split_index(strval, ',',  7) as time_message_generated,
        split_index(strval, ',',  8) as date_message_logged,
        split_index(strval, ',',  9) as time_message_logged,
        split_index(strval, ',', 10) as callsign,
        split_index(strval, ',', 11) as altitude,
        split_index(strval, ',', 12) as ground_speed,
        split_index(strval, ',', 13) as track,
        split_index(strval, ',', 14) as latitude,
        split_index(strval, ',', 15) as longitude,
        split_index(strval, ',', 16) as vertical_rate,
        split_index(strval, ',', 17) as squawk,
        split_index(strval, ',', 18) as alert,
        split_index(strval, ',', 19) as emergency,
        split_index(strval, ',', 20) as spi,
        split_index(strval, ',', 21) as is_on_ground 
    from cte
)
select
    key,
    `timestamp`,
    message_type,
    if(transmission_type = '', cast(null as int), cast(transmission_type as int)) as transmission_type,
    session_id,
    aircraft_id,
    hex_ident,
    flight_id,
    date_message_generated,
    time_message_generated,
    date_message_logged,
    time_message_logged,
    callsign,
    altitude,
    ground_speed,
    track,
    if(latitude = '', cast(null as double), cast(latitude as double)) as latitude,
    if(longitude = '', cast(null as double), cast(longitude as double)) as longitude,
    vertical_rate,
    squawk,
    alert,
    emergency,
    spi,
    is_on_ground 
from cte2
