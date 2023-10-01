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
    try_cast(transmission_type as bigint) as transmission_type,
    try_cast(session_id as bigint) as session_id,
    try_cast(aircraft_id as bigint) as aircraft_id,
    hex_ident,
    try_cast(flight_id as bigint) as flight_id,
    date_message_generated,
    time_message_generated,
    date_message_logged,
    time_message_logged,
    callsign,
    try_cast(altitude as bigint) as altitude,
    try_cast(ground_speed as double) as ground_speed,
    try_cast(track as double) as track,
    try_cast(latitude as double) as latitude,
    try_cast(longitude as double) as longitude,
    try_cast(vertical_rate as bigint) as vertical_rate,
    squawk,
    try_cast(alert as bigint) as alert,
    try_cast(emergency as bigint) as emergency,
    try_cast(spi as bigint) as spi,
    try_cast(is_on_ground as bigint) as is_on_ground 
from cte2
