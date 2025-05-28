import csv
import matplotlib.pyplot as plt
def visualize(value_received):
    value_received = "csv\\"+value_received
    # Initialize dictionaries to store data for each day
    data = {'Su': [], 'Mo': [], 'Tu': [], 'We': [], 'Th': [], 'Fr': [], 'Sa': []}

    # Open the CSV file and read data into the dictionaries
    with open(value_received, 'r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            day = row['Day']
            hour = int(row['Hour'])
            occupancy = int(row['OccupancyPercent'])
            data[day].append((hour, occupancy))

    # Plot the data for each day
    plt.figure(figsize=(10, 6))  # Set the size of the plot
    for day, values in data.items():
        hours, occupancy = zip(*values)
        plt.plot(hours, occupancy, label=day)

    plt.xlabel('Hour')
    plt.ylabel('Occupancy (%)')
    plt.title('Occupancy Percentage by Hour for Each Day')
    plt.legend()
    plt.grid(True)
    plt.show()  
