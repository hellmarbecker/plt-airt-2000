alter table `adsb-avro` ADD (
  `headers` MAP<BYTES, BYTES> METADATA VIRTUAL  
)
