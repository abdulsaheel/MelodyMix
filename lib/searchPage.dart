import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'audio_player_service.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'playlist_screen.dart';

class TopQueryResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  AudioPlayerService _audioPlayerService = AudioPlayerService();

  TopQueryResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final type = result['type'];
        final id = result['id'];

        switch (type) {
          case 'artist':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArtistScreen(artistId: id)));
            break;

          case 'song':
            _audioPlayerService.addToPlaylist(id);

          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => AudioPlayerScreen(songId: id)));
          //   break;
          case 'album':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlbumScreen(albumId: id)));
            break;
          case 'playlist':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlaylistScreen(playlistId: id)));
            break;
          default:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlbumScreen(albumId: id)));
            break;
        }
      },
      child: ListTile(
        title: Text(result['title']),
        subtitle: Text(result['description']),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(result['images'][0]['url']),
        ),
      ),
    );
  }
}

class SongResultTile extends StatelessWidget {
  AudioPlayerService _audioPlayerService = AudioPlayerService();

  final Map<String, dynamic> song;

  SongResultTile({required this.song});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _audioPlayerService.addToPlaylist(song['id']);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AudioPlayerScreen(
        //       songId: song['id'] ?? 'Unknown',
        //     ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Song Image on the left
            Container(
              width: 80,
              height: 80,
              child: Image.network(
                song['images'][0]['url'],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Song Info on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song['album'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song['singers'].join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistResultTile extends StatelessWidget {
  final Map<String, dynamic> artist;

  ArtistResultTile({required this.artist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistScreen(
              artistId: artist['id'],
            ),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(artist['images'][0]['url']),
          ),
          const SizedBox(height: 8),
          Text(
            artist['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PlaylistResultTile extends StatelessWidget {
  final Map<String, dynamic> playlist;

  PlaylistResultTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistScreen(
              playlistId: playlist['id'] ?? 'Unknown',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(playlist['images'][0]['url']),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class AlbumResultTile extends StatelessWidget {
  final Map<String, dynamic> album;

  AlbumResultTile({required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumScreen(
              albumId: album['id'] ?? 'Unknown',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Image on the left
            Container(
              width: 80,
              height: 80,
              child: Image.network(
                album['images'][0]['url'],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Album Info on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    album['artists'].join(','),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _errorMessage;

  Future<Map<String, dynamic>> fetchSaavnData(String query) async {
    final url = Uri.parse('https://saavn.dev/api/search?query=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          final Map<String, dynamic> resultData = {};

          resultData['topQueryResults'] =
              (data['data']['topQuery']['results'] as List).map((result) {
            return {
              'id': result['id'],
              'title': result['title'],
              'type': result['type'],
              'description': result['description'],
              'images': (result['image'] as List).map((image) {
                return {
                  'quality': image['quality'],
                  'url': image['url'],
                };
              }).toList(),
            };
          }).toList();

          resultData['songs'] =
              (data['data']['songs']['results'] as List).map((song) {
            final singers = song['singers'] is String
                ? [song['singers']]
                : song['singers'] as List<String>;

            return {
              'id': song['id'],
              'title': song['title'],
              'album': song['album'],
              'url': song['url'],
              'description': song['description'],
              'primaryArtists': song['primaryArtists'],
              'singers': singers,
              'language': song['language'],
              'images': (song['image'] as List).map((image) {
                return {
                  'quality': image['quality'],
                  'url': image['url'],
                };
              }).toList(),
            };
          }).toList();

          resultData['albums'] =
              (data['data']['albums']['results'] as List).map((album) {
            return {
              'id': album['id'],
              'title': album['title'],
              'artist': album['artist'],
              'url': album['url'],
              'description': album['description'],
              'year': album['year'],
              'language': album['language'],
              'images': (album['image'] as List).map((image) {
                return {
                  'quality': image['quality'],
                  'url': image['url'],
                };
              }).toList(),
            };
          }).toList();

          resultData['artists'] =
              (data['data']['artists']['results'] as List).map((artist) {
            return {
              'id': artist['id'],
              'title': artist['title'],
              'type': artist['type'],
              'description': artist['description'],
              'images': (artist['image'] as List).map((image) {
                return {
                  'quality': image['quality'],
                  'url': image['url'],
                };
              }).toList(),
            };
          }).toList();

          resultData['playlists'] =
              (data['data']['playlists']['results'] as List).map((playlist) {
            return {
              'id': playlist['id'],
              'title': playlist['title'],
              'url': playlist['url'],
              'description': playlist['description'],
              'language': playlist['language'],
              'images': (playlist['image'] as List).map((image) {
                return {
                  'quality': image['quality'],
                  'url': image['url'],
                };
              }).toList(),
            };
          }).toList();

          return resultData;
        } else {
          throw Exception('Failed to fetch data.');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await fetchSaavnData(_searchController.text);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data == null
                    ? Center(child: Text(_errorMessage ?? 'No results found.'))
                    : ListView(
                        children: [
                          // Top Query Results
                          if (_data!['topQueryResults'].isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Top Query Results',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ..._data!['topQueryResults']
                              .map((result) =>
                                  TopQueryResultTile(result: result))
                              .toList(),

                          // Songs
                          if (_data!['songs'].isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Songs',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ..._data!['songs']
                              .map((song) => SongResultTile(song: song))
                              .toList(),

                          // Artists
                          if (_data!['artists'].isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Artists',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _data!['artists'].length,
                                  itemBuilder: (context, index) {
                                    final artist = _data!['artists'][index];
                                    return ArtistResultTile(artist: artist);
                                  },
                                ),
                              ],
                            ),

                          // Playlists
                          if (_data!['playlists'].isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Playlists',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 1.0,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _data!['playlists'].length,
                            itemBuilder: (context, index) {
                              final playlist = _data!['playlists'][index];
                              return PlaylistResultTile(playlist: playlist);
                            },
                          ),

                          // Albums
                          // Albums
                          if (_data!['albums'].isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Albums',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ..._data!['albums']
                              .map((album) => AlbumResultTile(album: album))
                              .toList(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
