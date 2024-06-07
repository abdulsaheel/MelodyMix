// artist_info.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// Data classes to hold artist information
class ArtistInfo {
  final String name;
  final String type;
  final String imageUrl;
  final String bio;
  final List<ArtistSong> topSongs;
  final List<ArtistAlbum> topAlbums;
  final List<ArtistSingle> singles;

  ArtistInfo({
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.bio,
    required this.topSongs,
    required this.topAlbums,
    required this.singles,
  });
}

class ArtistSong {
  final String name;
  final String id;
  final String url;
  final String imageUrl;
  final int duration;
  final List<ArtistDetail> artists;
  final List<ArtistDownloadUrl> downloadUrls;

  ArtistSong({
    required this.name,
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.duration,
    required this.artists,
    required this.downloadUrls,
  });
}

class ArtistAlbum {
  final String id;
  final String name;
  final int songCount;
  final String imageUrl;

  ArtistAlbum({
    required this.id,
    required this.name,
    required this.songCount,
    required this.imageUrl,
  });
}

class ArtistSingle {
  final String name;
  final String id;
  final String url;
  final String imageUrl;
  final List<ArtistDetail> artists;

  ArtistSingle({
    required this.name,
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.artists,
  });
}

class ArtistDetail {
  final String id;
  final String name;
  final String imageUrl;

  ArtistDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class ArtistDownloadUrl {
  final String quality;
  final String url;

  ArtistDownloadUrl({
    required this.quality,
    required this.url,
  });
}

Future<ArtistInfo?> fetchArtistInfo(String artistId) async {
  final String url = 'https://saavn.dev/api/artists/$artistId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);

      // Extract and construct relevant information
      final artistName = jsonResponse['data']['name'] ?? '';
      final artistType = jsonResponse['data']['type'] ?? '';
      final artistImage = (jsonResponse['data']['image']?.isNotEmpty ?? false)
          ? jsonResponse['data']['image'].last['url']
          : '';
      final artistBio = (jsonResponse['data']['bio']?.isNotEmpty ?? false)
          ? jsonResponse['data']['bio'][0]['text']
          : '';

      final topSongs =
          (jsonResponse['data']['topSongs'] ?? []).map<ArtistSong>((song) {
        final songArtists =
            (song['artists']['all'] ?? []).map<ArtistDetail>((artist) {
          return ArtistDetail(
            id: artist['id'] ?? '',
            name: artist['name'] ?? '',
            imageUrl: (artist['image']?.isNotEmpty ?? false)
                ? artist['image'].last['url']
                : '',
          );
        }).toList();

        final downloadUrls =
            (song['downloadUrl'] ?? []).map<ArtistDownloadUrl>((link) {
          return ArtistDownloadUrl(
            quality: link['quality'] ?? '',
            url: link['url'] ?? '',
          );
        }).toList();

        return ArtistSong(
          name: song['name'] ?? '',
          id: song['id'] ?? '',
          url: song['url'] ?? '',
          duration: song['duration'] ?? '',
          imageUrl: song['image'].last['url'] ?? '',
          artists: songArtists,
          downloadUrls: downloadUrls,
        );
      }).toList();

      final topAlbums =
          (jsonResponse['data']['topAlbums'] ?? []).map<ArtistAlbum>((album) {
        return ArtistAlbum(
          id: album['id'] ?? '',
          name: album['name'] ?? '',
          songCount: album['songCount'] ?? '',
          imageUrl: (album['image']?.isNotEmpty ?? false)
              ? album['image'].last['url']
              : '',
        );
      }).toList();

      final singles =
          (jsonResponse['data']['singles'] ?? []).map<ArtistSingle>((single) {
        final singleArtists =
            (single['artists']['all'] ?? []).map<ArtistDetail>((artist) {
          return ArtistDetail(
            id: artist['id'] ?? '',
            name: artist['name'] ?? '',
            imageUrl: (artist['image']?.isNotEmpty ?? false)
                ? artist['image'].last['url']
                : '',
          );
        }).toList();

        return ArtistSingle(
          name: single['name'] ?? '',
          id: single['id'] ?? '',
          url: single['url'] ?? '',
          imageUrl: (single['image']?.isNotEmpty ?? false)
              ? single['image'].last['url']
              : '',
          artists: singleArtists,
        );
      }).toList();

      return ArtistInfo(
        name: artistName,
        type: artistType,
        imageUrl: artistImage,
        bio: artistBio,
        topSongs: topSongs,
        topAlbums: topAlbums,
        singles: singles,
      );
    } else {
      print('Failed to fetch artist info. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to fetch artist info: $e');
  }
  return null;
}
