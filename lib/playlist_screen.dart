// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'artist_screen.dart';
import 'audio_player_service.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistId;

  PlaylistScreen({required this.playlistId});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Map<String, dynamic>? playlistData;
  List<dynamic>? songs;
  bool isLoading = true;
  String errorMessage = '';
  int currentPage = 1;
  bool isFetchingMore = false;
  final _scrollController = ScrollController();
  AudioPlayerService _audioPlayerService = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    fetchPlaylist(widget.playlistId, currentPage);

    // Add scroll listener
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener function
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom
      if (!isFetchingMore) {
        currentPage++;
        fetchPlaylist(widget.playlistId, currentPage);
      }
    }
  }

  Future<void> fetchPlaylist(String playlistId, int page) async {
    final String baseUrl = 'https://saavn.dev/api';
    final String apiUrl = '$baseUrl/playlists?id=$playlistId&page=$page';

    setState(() {
      isFetchingMore = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          final playlist = json.decode(response.body);
          if (currentPage == 1) {
            playlistData = playlist;
            songs = playlist['data']['songs'].toList();
          } else {
            songs!.addAll(playlist['data']['songs']);
          }
          isLoading = false;
          isFetchingMore = false; // Reset fetching flag
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load playlist data';
          isLoading = false;
          isFetchingMore = false; // Reset fetching flag
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
        isFetchingMore = false; // Reset fetching flag
      });
    }
  }

  Widget _buildSongList() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs!.length,
          itemBuilder: (context, index) {
            final song = songs![index];

            // Extracting artist names
            List<String> artistNames = [];
            for (var artist in song['artists']['primary']) {
              artistNames.add(artist['name']);
            }

            // Joining artist names with commas
            String artistsString = artistNames.join(', ');

            // Converting duration from seconds to minutes and seconds
            int durationSeconds = song['duration'];
            String durationString =
                '${(durationSeconds ~/ 60).toString().padLeft(2, '0')}:${(durationSeconds % 60).toString().padLeft(2, '0')}';

            return ListTile(
              title: Text(song['name']),
              subtitle: Text(artistsString),
              trailing: Text(durationString),
              leading: (song['image'] as List).isNotEmpty
                  ? Image.network(
                      song['image'].last['url'],
                      width: 70,
                      height: 70,
                    )
                  : null,
              onTap: () {
                // Handle song tap
                _audioPlayerService.addToPlaylist(song['id']);
              },
            );
          },
        ),
        if (isFetchingMore) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildArtists() {
    final List<dynamic> artists = playlistData!['data']['artists'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Artists',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: artists
                .fold<List<Map<String, dynamic>>>([], (prev, artist) {
                  // Check if the artist ID is already in the list
                  if (!prev
                      .any((prevArtist) => prevArtist['id'] == artist['id'])) {
                    prev.add(artist);
                  }
                  return prev;
                })
                .map<Widget>((artist) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArtistScreen(artistId: artist['id']),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                artist['image'].isNotEmpty
                                    ? artist['image'].last['url']
                                    : 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // This builder function will be called if there's an error loading the image
                                  return Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              artist['name'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Role: ${artist['role']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey[300]!),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    playlistData!['data']['image'][0]['url'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlistData!['data']['name'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    playlistData!['data']['description'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildArtists(), // Show artists above songs
                      const SizedBox(
                          height: 20), // Add some spacing between sections
                      _buildSongList(),
                    ],
                  ),
                ),
    );
  }
}
