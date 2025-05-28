import requests
import os

def get_place_url(place_name):
    api_key = os.getenv("GOOGLE_MAPS_API_KEY")
    search_url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    
    params = {
        "input": place_name,
        "inputtype": "textquery",
        "fields": "place_id",
        "key": api_key
    }

    response = requests.get(search_url, params=params)
    response.raise_for_status()
    data = response.json()

    if not data.get("candidates"):
        raise ValueError(f"No place found for name: {place_name}")
    
    place_id = data["candidates"][0]["place_id"]
    maps_url = f"https://www.google.com/maps/place/?q=place_id:{place_id}"
    return maps_url