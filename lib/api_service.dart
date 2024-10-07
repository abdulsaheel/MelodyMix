import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  final String homebaseUrl = 'https://jio-savn-six.vercel.app/modules';
  final String baseUrl = 'https://jiosaavan-test-ten.vercel.app/api';

  Future<Map<String, dynamic>> fetchAlbumData(String videoId) async {
    final String apiUrl = '$baseUrl/albums?id=$videoId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load album data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchData(List<String> languages) async {
    final response = await http
        .get(Uri.parse('$homebaseUrl?language=${languages.join(',')}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
