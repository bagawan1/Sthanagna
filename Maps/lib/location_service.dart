import 'consts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = GOOGLE_MAPS_API_KEY;
  final String flaskServerUrl = 'http://10.0.2.2:5000/ner';

  Future<String> extractPlaceName(String sentence) async {
    try {
      final response = await http.post(
        Uri.parse(flaskServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({'text': sentence}),
      );

      if (response.statusCode == 200) {
        var json = convert.jsonDecode(response.body);
        for (var entity in json) {
          if (entity['entity'] == 'B-LOC' || entity['entity'] == 'I-LOC') {
            return entity['word'];
          }
        }
        throw Exception('No location entity found in the sentence.');
      } else {
        throw Exception('Failed to extract place name from sentence. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error extracting place name: $e');
      rethrow;
    }
  }

  Future<String> getPlaceId(String input) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var json = convert.jsonDecode(response.body);
        var placeId = json['candidates'][0]['place_id'] as String;
        return placeId;
      } else {
        throw Exception('Failed to get place ID. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place ID: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlace(String sentence) async {
    try {
      final placeName = await extractPlaceName(sentence);
      final placeId = await getPlaceId(placeName);
      final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var json = convert.jsonDecode(response.body);
        var results = json['result'] as Map<String, dynamic>;
        print(results);
        return results;
      } else {
        throw Exception('Failed to get place details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place: $e');
      rethrow;
    }
  }
}
