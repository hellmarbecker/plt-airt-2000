import csv
import json

BASEPATH = './flight_delays_kaggle_archive/'

def slurp(fn):

    with open(BASEPATH + fn, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        return { row[reader.fieldnames[0]]:row for row in reader }

def main():
    print(json.dumps(slurp('airlines.csv')))
    print(json.dumps(slurp('airports.csv')))

if __name__ == "__main__":
    main()
