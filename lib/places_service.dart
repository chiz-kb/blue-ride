import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description,placeId: $placeId)';
  }
}
late LatLng add;
class PlaceApiProvider {
  PlaceApiProvider._inernal();
  static PlaceApiProvider get instance =>PlaceApiProvider._inernal();
  final client = Client();
  final sessionToken=Uuid().v4();
  PlaceApiProvider();

  static const String androidKey = 'AIzaSyCEFmYjU1qSau0zS3G_LedL89cTNkhZ6KA';
  final apiKey = androidKey;

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=En&components=country:et&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((p) => Suggestion(p['place_id'], p['description'])).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
  
  Future<String> fetchPlace(lat,lang) async {
  final response = await get(Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lang&key=AIzaSyCEFmYjU1qSau0zS3G_LedL89cTNkhZ6KA'));
  
  if (response.statusCode == 200) {
    final result=json.decode(response.body);
    // If the server did return a 200 OK response,
    // then parse the JSON.
    if(result['status']=='OK'){
      // print(result['plus_code']['compound_code']);
      return result['plus_code']['compound_code'];

    }
    throw Exception(result['error_message']);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load place info');
  }
 }
 Future<LatLng> fetchLatLang(placeId) async {
  final response = await get(Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=AIzaSyCEFmYjU1qSau0zS3G_LedL89cTNkhZ6KA'));
  
  if (response.statusCode == 200) {
    final result=json.decode(response.body);
    // If the server did return a 200 OK response,
    // then parse the JSON.
    if(result['status']=='OK'){
      // print(result['plus_code']['compound_code']);
      add=LatLng(result['results'][0]['geometry']['location']['lat'], result['results'][0]['geometry']['location']['lng']);
      return add;

    }
    throw Exception(result['error_message']);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load place info');
  }
 }
}
