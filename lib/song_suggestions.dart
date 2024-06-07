// song_suggestions.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getSongSuggestions(String id) async {
  final String url = 'https://saavn.dev/api/songs/$id/suggestions';
  List<Map<String, dynamic>> suggestionsList = [];

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success']) {
        List suggestions = data['data'];

        for (var suggestion in suggestions) {
          Map<String, dynamic> suggestionInfo = {
            'ID': suggestion['id'],
            'Name': suggestion['name'],
            'Type': suggestion['type'],
            'Year': suggestion['year'],
            'Release Date': suggestion['releaseDate'],
            'Duration': suggestion['duration'],
            'Label': suggestion['label'],
            'Explicit Content': suggestion['explicitContent'],
            'Play Count': suggestion['playCount'],
            'Language': suggestion['language'],
            'Has Lyrics': suggestion['hasLyrics'],
            'Lyrics ID': suggestion['lyricsId'],
            'URL': suggestion['url'],
            'Copyright': suggestion['copyright'],
            'Album': {
              'Album ID': suggestion['album']['id'],
              'Album Name': suggestion['album']['name'],
              'Album URL': suggestion['album']['url'],
            },
            'Primary Artists': suggestion['artists']['primary']
                .map((artist) => {
                      'Artist ID': artist['id'],
                      'Artist Name': artist['name'],
                      'Role': artist['role'],
                      'Images': artist['image']
                          .map((image) => {
                                'Image Quality': image['quality'],
                                'Image URL': image['url'],
                              })
                          .toList(),
                    })
                .toList(),
            'Featured Artists': suggestion['artists']['featured']
                .map((artist) => {
                      'Artist ID': artist['id'],
                      'Artist Name': artist['name'],
                      'Role': artist['role'],
                      'Images': artist['image']
                          .map((image) => {
                                'Image Quality': image['quality'],
                                'Image URL': image['url'],
                              })
                          .toList(),
                    })
                .toList(),
            'All Artists': suggestion['artists']['all']
                .map((artist) => {
                      'Artist ID': artist['id'],
                      'Artist Name': artist['name'],
                      'Role': artist['role'],
                      'Images': artist['image']
                          .map((image) => {
                                'Image Quality': image['quality'],
                                'Image URL': image['url'],
                              })
                          .toList(),
                    })
                .toList(),
            'Images': suggestion['image']
                .map((image) => {
                      'Image Quality': image['quality'],
                      'Image URL': image['url'],
                    })
                .toList(),
            'Download URLs': suggestion['downloadUrl']
                .map((downloadUrl) => {
                      'Quality': downloadUrl['quality'],
                      'URL': downloadUrl['url'],
                    })
                .toList(),
          };

          suggestionsList.add(suggestionInfo);
        }
      } else {
        throw Exception('Failed to get song suggestions: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load suggestions: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }

  return suggestionsList;
}
