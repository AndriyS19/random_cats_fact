import 'dart:convert';
import 'package:http/http.dart' as http;

class CatService {
  static const String _factBaseUrl = 'https://catfact.ninja';
  // static const String _imageBaseUrl = 'https://cataas.com';
  static const String _imageBaseUrl = 'https://cataas.com/cat';

  Future<Map<String, dynamic>> getRandomCatData() async {
    try {
      // Get fact and image in parallel
      final results = await Future.wait([
        _getRandomFact(),
        _getRandomImage(),
      ]);

      return {
        'fact': results[0],
        'imageUrl': results[1],
      };
    } catch (e) {
      throw Exception('Failed to fetch cat data: $e');
    }
  }

  Future<String> _getRandomFact() async {
    final response = await http.get(Uri.parse('$_factBaseUrl/fact'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['fact'];
    } else {
      throw Exception('Failed to load cat fact');
    }
  }

  Future<String> _getRandomImage() async {
    final response = await http.get(Uri.parse(_imageBaseUrl));

    if (response.statusCode == 200) {
      return '$_imageBaseUrl/cat?timestamp=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      throw Exception('Failed to load cat image');
    }
  }
}
