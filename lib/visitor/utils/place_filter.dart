import '../models/place_model.dart';

class PlaceFilterUtils {
  // Filter places by minimum rating
  static List<Place> filterByRating(List<Place> places, double minRating) {
    return places.where((place) => place.rating >= minRating).toList();
  }

  // Filter places by price range
  static List<Place> filterByPrice(List<Place> places, int minPrice, int maxPrice) {
    return places.where((place) {
      int price = int.tryParse(place.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  // Filter places by maximum distance
  static List<Place> filterByDistance(List<Place> places, double maxDistance) {
    return places.where((place) {
      double distance = double.tryParse(place.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return distance <= maxDistance;
    }).toList();
  }

  // Filter places by labels (Crowded, Comfy, etc.)
  static List<Place> filterByLabel(List<Place> places, List<String> labels) {
    if (labels.isEmpty) return places;
    return places.where((place) =>
        labels.any((label) => place.label.toLowerCase() == label.toLowerCase())
    ).toList();
  }

  // Filter places by amenities
  static List<Place> filterByAmenities(List<Place> places, List<String> amenities) {
    if (amenities.isEmpty) return places;
    return places.where((place) =>
        amenities.any((amenity) =>
            place.amenities.any((placeAmenity) =>
                placeAmenity.toLowerCase().contains(amenity.toLowerCase())
            )
        )
    ).toList();
  }

  // Search places by query (title, location, description, amenities)
  static List<Place> searchPlaces(List<Place> places, String query) {
    if (query.isEmpty) return places;

    final lowercaseQuery = query.toLowerCase();
    return places.where((place) =>
    place.title.toLowerCase().contains(lowercaseQuery) ||
        place.address.toLowerCase().contains(lowercaseQuery) ||
        place.description.toLowerCase().contains(lowercaseQuery) ||
        place.amenities.any((amenity) => amenity.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Sort places by rating (highest first)
  static List<Place> sortByRating(List<Place> places, {bool ascending = false}) {
    List<Place> sortedPlaces = List.from(places);
    sortedPlaces.sort((a, b) => ascending ? a.rating.compareTo(b.rating) : b.rating.compareTo(a.rating));
    return sortedPlaces;
  }

  // Sort places by distance (nearest first)
  static List<Place> sortByDistance(List<Place> places, {bool ascending = true}) {
    List<Place> sortedPlaces = List.from(places);
    sortedPlaces.sort((a, b) {
      double distanceA = double.tryParse(a.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      double distanceB = double.tryParse(b.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return ascending ? distanceA.compareTo(distanceB) : distanceB.compareTo(distanceA);
    });
    return sortedPlaces;
  }

  // Sort places by price (lowest first)
  static List<Place> sortByPrice(List<Place> places, {bool ascending = true}) {
    List<Place> sortedPlaces = List.from(places);
    sortedPlaces.sort((a, b) {
      int priceA = int.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int priceB = int.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return sortedPlaces;
  }

  // Get favorite places only
  static List<Place> getFavorites(List<Place> places) {
    return places.where((place) => place.isFavorite).toList();
  }

  // Combined filter method
  static List<Place> applyFilters(
      List<Place> places, {
        String? searchQuery,
        double? minRating,
        int? minPrice,
        int? maxPrice,
        double? maxDistance,
        List<String>? labels,
        List<String>? amenities,
        bool? favoritesOnly,
      }) {
    List<Place> filteredPlaces = List.from(places);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredPlaces = searchPlaces(filteredPlaces, searchQuery);
    }

    if (minRating != null) {
      filteredPlaces = filterByRating(filteredPlaces, minRating);
    }

    if (minPrice != null && maxPrice != null) {
      filteredPlaces = filterByPrice(filteredPlaces, minPrice, maxPrice);
    }

    if (maxDistance != null) {
      filteredPlaces = filterByDistance(filteredPlaces, maxDistance);
    }

    if (labels != null && labels.isNotEmpty) {
      filteredPlaces = filterByLabel(filteredPlaces, labels);
    }

    if (amenities != null && amenities.isNotEmpty) {
      filteredPlaces = filterByAmenities(filteredPlaces, amenities);
    }

    if (favoritesOnly == true) {
      filteredPlaces = getFavorites(filteredPlaces);
    }

    return filteredPlaces;
  }
}