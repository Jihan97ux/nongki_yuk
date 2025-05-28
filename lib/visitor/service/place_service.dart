import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';

class PlaceService {
  static const String baseUrl = 'https://nongkiyuk-6763e-default-rtdb.asia-southeast1.firebasedatabase.app';

  static Future<List<Place>> fetchCafesFromFirebase() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cafe.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        List<Place> places = [];
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            value['id'] = value['id'] ?? key;
            places.add(Place.fromJson(value));
          }
        });

        return places;
      } else {
        throw Exception('Failed to load cafes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cafes: $e');
    }
  }

  // Get all places from Firebase only
  static Future<List<Place>> getAllPlaces() async {
    try {
      return await fetchCafesFromFirebase();
    } catch (e) {
      print('Error getting places from Firebase: $e');
      throw Exception('Failed to fetch places from Firebase: $e');
    }
  }
}