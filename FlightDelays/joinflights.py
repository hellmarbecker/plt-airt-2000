import csv
import json

BASEPATH = './flight_delays_kaggle_archive/'

def slurp(fn):

    with open(BASEPATH + fn, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        return { row[reader.fieldnames[0]]:row for row in reader }

def main():

    airlines = slurp('airlines.csv')
    airports = slurp('airports.csv')

    with open(BASEPATH + 'flights.csv', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            row['AIRLINE'] = airlines[row['AIRLINE']]
            row['ORIGIN_AIRPORT'] = airports[row['ORIGIN_AIRPORT']]
            row['DESTINATION_AIRPORT'] = airports[row['DESTINATION_AIRPORT']]
            print(json.dumps(row))

if __name__ == "__main__":
    main()
