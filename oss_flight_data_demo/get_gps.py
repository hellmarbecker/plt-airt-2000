from pigps import GPS
from time import sleep
gps = GPS()
sleep(5)
if gps.time != 0:
    with open("/home/admin/time.txt","w") as file:
        print("Got gps time", gps.time)
        file.write(str(gps.time))

if gps.lat != 0:
    with open("/home/admin/lat.txt","w") as file:
        print("Got gps lat", gps.lat)
        file.write(str(gps.lat))

if gps.lon != 0:
    with open("/home/admin/lon.txt","w") as file:
        print("Got gps lon", gps.lon)
        file.write(str(gps.lon))