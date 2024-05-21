# OSS Flight Data Demo

## Quick start

1. Run `docker compose --profile default up -d`.       

2. Ingest data into [Druid](https://localhost:8888) from adsb-json topic with the spec in plt-airt-2000/oss_flight_data_demo/druid/ingestion_spec.json (insert credentials where appropriate).

3. After all messages have been ingested you can check out visualisations in [Grafana](localhost:3000)

## TODO

* Use Flink to (or otherwise) consolidate/filter records for aircraft to reduce the number of null longitudes, latitudes, and altitudes
* Deploy using Minikube instead of docker? (with a view to rolling this out to learn Druid)
