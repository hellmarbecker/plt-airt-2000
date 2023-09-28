with cte as (
    select
        decode(key, 'UTF-8') as strkey,
        decode(val, 'UTF-8') as strval
    from `adsb-raw`
) select
    split_index(strval, ',',  6) || ' ' || split_index(strval, ',',  7) as __time,
    split_index(strval, ',',  0) as message_type,
    cast(split_index(strval, ',',  1) as integer) as transmission_type,
    cast(split_index(strval, ',',  2) as integer) as session_id,
    cast(split_index(strval, ',',  3) as integer) as aircraft_id,
    split_index(strval, ',',  4) as hex_ident,
    cast(split_index(strval, ',',  5) as integer) as flight_id,
    split_index(strval, ',',  6) as date_message_generated,
    split_index(strval, ',',  7) as time_message_generated,
    split_index(strval, ',',  8) as date_message_logged,
    split_index(strval, ',',  9) as time_message_logged,
    split_index(strval, ',', 10) as callsign,
    cast(split_index(strval, ',', 11) as integer) as altitude,
    cast(split_index(strval, ',', 12) as double) as ground_speed,
    cast(split_index(strval, ',', 13) as double) as track,
    cast(split_index(strval, ',', 14) as double) as latitude,
    cast(split_index(strval, ',', 15) as double) as longitude,
    cast(split_index(strval, ',', 16) as integer) as vertical_rate,
    split_index(strval, ',', 17) as squawk,
    cast(split_index(strval, ',', 18) as integer) as alert,
    cast(split_index(strval, ',', 19) as integer) as emergency,
    cast(split_index(strval, ',', 20) as integer) as spi,
    cast(split_index(strval, ',', 21) as integer) as is_on_ground
from cte
