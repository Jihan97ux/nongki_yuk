import functions.utils.scrapmaps as scrapmaps
import functions.utils.store_to_firebase as store_to_firebase
import functions.utils.get_link as get_link
import functions.utils.populer_time as populer_time
import os
import functions.utils.DataVisualization as DataVisualization
from functions import banner


place = input("Enter Your Place: ")
maps_url = get_link.get_place_url(place)
print(maps_url)
print("Sending Data....")
item,result = scrapmaps.scraper(maps_url)
print(result)
store_to_firebase.process_and_store_to_firebase(item)
banner.press_enter_to_continue()
os.system('cls')
