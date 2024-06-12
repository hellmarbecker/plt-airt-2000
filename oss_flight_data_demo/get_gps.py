from pigps import GPS
from time import sleep
gps = GPS()
sleep(5)
print(gps.time,gps.lat,gps.lon)
if gps.time != "0":
    with open("/home/admin/time.txt","w") as file:
        file.write(str(gps.time))

if gps.lat != "0.0":
    with open("/home/admin/lat.txt","w") as file:
        file.write(str(gps.lat))

if gps.lon != "0.0":
    with open("/home/admin/lon.txt","w") as file:
        file.write(str(gps.lon))