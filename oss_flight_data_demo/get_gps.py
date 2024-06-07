import os
from pigps import GPS
from time import sleep
gps = GPS()
sleep(30)
with open("/home/admin/time.txt","w") as file:
    file.write(str(gps.time))
with open("/home/admin/lat.txt","w") as file:
    file.write(str(gps.lat))
with open("/home/admin/lon.txt","w") as file:
    file.write(str(gps.lon))
