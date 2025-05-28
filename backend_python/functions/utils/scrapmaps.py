import os
import json
from dotenv import load_dotenv
from apify_client import ApifyClient

load_dotenv()
def scraper(value_received):
    api_key = os.getenv("APIFY_API_KEY")
    apify_client = ApifyClient(api_key)

    run_input = {
        "deeperCityScrape": False,
        "includeWebResults": False,
        "language": "en",
        "maxCrawledPlacesPerSearch": 50,
        "maxImages": 1,
        "maxQuestions": 0,
        "maxReviews": 0,
        "onlyDataFromSearchPage": False,
        "scrapeDirectories": False,
        "scrapeResponseFromOwnerText": True,
        "scrapeReviewId": True,
        "scrapeReviewUrl": True,
        "scrapeReviewerId": True,
        "scrapeReviewerName": True,
        "scrapeReviewerUrl": True,
        "skipClosedPlaces": False,
        "startUrls": [
            {
            "url": value_received,
            }
        ],
        "reviewsSort": "newest",
        "reviewsFilterString": "",
        "searchMatching": "all",
        "placeMinimumStars": "",
        "allPlacesNoSearchAction": ""
    }
    run = apify_client.actor("nwua9Gu5YrADL7ZDj").call(run_input=run_input)
    for item in apify_client.dataset(run["defaultDatasetId"]).iterate_items():
       filename="datasets\\"+item["title"]+".json"
       filename = filename.replace(" ","")
       with open(filename, "w") as outfile:
          json.dump(item,outfile)
        #print(item)
       result = "Gatherd Data Saved in to" + filename +'\n'
    return item, result

