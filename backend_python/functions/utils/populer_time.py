import json
import pandas as pd
import csv

def analize(value_received):
    value_received = "datasets\\"+value_received
    f = open(value_received)
    data = json.load(f)
    print("URL: ",data["searchString"])
    print("Title: ",data["title"])
    print("category: ",data["categoryName"])
    print("Address: ", data["address"])
    print("Country Code: ", data["countryCode"])
    print("Web: ",data["website"])
    print("Location: ","Latitude: ",data["location"]["lat"]," ", "Longtude:", data['location']['lng'])
    print("*********************************************************************")
    rows = []
    for day, hours_data in data["popularTimesHistogram"].items():
        for hour_data in hours_data:
            row = {
                "Day": day,
                "Hour": hour_data["hour"],
                "OccupancyPercent": hour_data["occupancyPercent"]
            }
            rows.append(row)
    df = pd.DataFrame(rows)
    def day_to_number(day):
        days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
        return days.index(day)
    sorted_data = sorted(rows, key=lambda x: (day_to_number(x['Day']), x['Hour']))
    print("+-----+-------+---------------------+")
    print("| Day |  Hour | OccupancyPercent    |")
    print("+-----+-------+---------------------+")
    for row in sorted_data[:10]:
        print(f"| {row['Day']:3} | {row['Hour']:5} | {row['OccupancyPercent']:19} |")
    print("+-----+-------+---------------------+\n")

    csv_file_path = "csv\\"+data["title"]+".csv"
    csv_file_path = csv_file_path.replace(" ","")
    with open(csv_file_path, mode='w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=sorted_data[0].keys())
        writer.writeheader()
        writer.writerows(sorted_data)
    result = f"Sorted data has been written to '{csv_file_path}'.\n"
    return result