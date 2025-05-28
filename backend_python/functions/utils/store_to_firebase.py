import firebase_admin
from firebase_admin import credentials, db

if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://nongkiyuk-6763e-default-rtdb.asia-southeast1.firebasedatabase.app/'
    })
    
def process_and_store_to_firebase(data):
    print(f"\nProcessing: {data.get('title')}")

    amenities_input = input("Input amenities (pisah koma): ")
    data["amenities"] = [a.strip() for a in amenities_input.split(",")]

    if not data.get("price"):
        data["price"] = input("Price is empty. Enter price: ")
    if not data.get("description"):
        data["description"] = input("Description is empty. Enter description: ")

    ref = db.reference("/cafe")
    ref.push(data)
    print(f"'{data['title']}' stored in Firebase.\n")