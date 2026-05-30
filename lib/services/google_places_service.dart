import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const apiKey = 'AIzaSyAyqkl0q83FOJio1Jk9_qM5lGnJ4awNL_Y';

  static Future<Map<String, double>?> getCoordinates(
      String place) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=$place'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data['results'].isEmpty) {
      return null;
    }

    final location =
    data['results'][0]['geometry']['location'];

    return {
      'lat': location['lat'],
      'lng': location['lng'],
    };
  }
}