DROP STREAM `adsb_raw`;

CREATE OR REPLACE STREAM `adsb_raw` (                            
    `message_type`            VARCHAR,
    `transmission_type`       INTEGER,
    `session_id`              INTEGER,
    `aircraft_id`             INTEGER,
    `hex_ident`               VARCHAR,
    `flight_id`               INTEGER,
    `date_message_generated`  VARCHAR,
    `time_message_generated`  VARCHAR,
    `date_message_logged`     VARCHAR,
    `time_message_logged`     VARCHAR,
    `callsign`                VARCHAR,
    `altitude`                INTEGER,
    `ground_speed`            DOUBLE,
    `track`                   DOUBLE,
    `latitude`                DOUBLE,
    `longitude`               DOUBLE,
    `vertical_rate`           INTEGER,
    `squawk`                  VARCHAR,
    `alert`                   INTEGER,
    `emergency`               INTEGER,
    `spi`                     INTEGER,
    `is_on_ground`            INTEGER,
    `client_id`               BYTES HEADER('ClientID'),
    `client_lon`              BYTES HEADER('ReceiverLon'),
    `client_lat`              BYTES HEADER('ReceiverLat'),
    `headers`                 ARRAY<STRUCT<key STRING, value BYTES>> HEADERS
)
WITH (
    KAFKA_TOPIC='adsb-raw',
    VALUE_FORMAT='DELIMITED'
);
