import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/place_model.dart';

class DistanceService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static Future<String> getDistance({
    required double userLat,
    required double userLng,
    required double placeLat,
    required double placeLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$userLat,$userLng'
          '&destinations=$placeLat,$placeLng'
          '&mode=driving'
          '&units=metric'
          '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      print('Distance API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['rows'] != null &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          final distanceText = data['rows'][0]['elements'][0]['distance']['text'];
          return distanceText;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch distance: ${response.statusCode}');
      }
    } catch (e) {
      print('Distance API error: $e');
      return 'Unknown';
    }
  }
}
