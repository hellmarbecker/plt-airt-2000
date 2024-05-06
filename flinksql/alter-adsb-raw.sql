alter table `adsb-raw` ADD (
  `headers` MAP<BYTES, BYTES> METADATA VIRTUAL  
)
