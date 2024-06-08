import 'package:flutter/material.dart';
import 'mini_player.dart'; // Import the MiniPlayerWidget
import 'album_screen.dart';
import 'playlist_screen.dart';
import 'searchPage.dart';
import 'audio_player_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class MyHomePage extends StatefulWidget {
  final List<Map<String, dynamic>> trendingSongs;
  final List<Map<String, dynamic>> trendingAlbums;
  final List<Map<String, dynamic>> albums;
  final List<Map<String, dynamic>> playlists;

  MyHomePage({
    required this.trendingSongs,
    required this.trendingAlbums,
    required this.albums,
    required this.playlists,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(
                255, 0, 140, 255), // Add a background with opacity
            width: 10,
            height: 10,
            padding: const EdgeInsets.only(bottom: 8),
          ),
          ListView(
            children: [
              _buildTrendingSongsSection(),
              const SizedBox(height: 16.0),
              _buildTrendingAlbumsSection(),
              const SizedBox(height: 16.0),
              _buildPlaylistsSection(),
              const SizedBox(height: 16.0),
              _buildAlbumSection('Albums', widget.albums),
              const SizedBox(height: 100.0),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MiniPlayerWidget(), // Add the MiniPlayerWidget at the bottom
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSongsSection() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hit Play on the Freshest Tunes! 🎧🎶🤩',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.trendingSongs.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildTrendingSongItem(widget.trendingSongs[index]);
              },
            ),
          ],
        ));
  }

  Widget _buildTrendingSongItem(Map<String, dynamic> song) {
    AudioPlayerService _audioPlayerService = AudioPlayerService();
    return GestureDetector(
      onTap: () {
        // Call the playSong method with the song ID
        _audioPlayerService.addToPlaylist(song['id']);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            song['image'] ?? 'https://via.placeholder.com/50',
            fit: BoxFit.cover,
            height: 50.0,
            width: 50.0,
          ),
        ),
        title: Text(
          song['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        subtitle: Text(_getArtistsNames(song['primaryArtists'])),
        trailing: Text(
          _formatDuration(song['duration']),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _getArtistsNames(List<dynamic> artists) {
    if (artists.isEmpty) {
      return 'Unknown Artist';
    }
    List<String> artistNames =
        artists.map((artist) => artist['name'] as String).toList();
    return artistNames.join(', ');
  }

  String _formatDuration(dynamic duration) {
    if (duration is String) {
      duration = int.tryParse(duration) ?? 0;
    }
    if (duration is! int) {
      return '00:00';
    }
    int minutes = duration ~/ 60;
    int remainingSeconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTrendingAlbumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 0.8),
          // Apply padding only to the text
          child: Text(
            'Trending Albums',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 300.0, // Adjust container height if needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.trendingAlbums.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildTrendingAlbumItem(widget.trendingAlbums[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection() {
    if (kIsWeb || Platform.isWindows) {
      return _buildPlaylistsForWeb();
    } else {
      return _buildPlaylistsForMobile();
    }
  }

  Widget _buildPlaylistsForWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 0.8),
          // Apply padding only to the text
          child: Row(
            children: [
              Text(
                'Swipe to Discover Your Mood.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(width: 8.0), // Add space between text and icon
              Icon(Icons.swipe, size: 16.0), // Arrow icon
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth / 4;
            final int columns = (constraints.maxWidth / itemWidth).floor();

            return Container(
              height: 300.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    (widget.playlists.length / columns).ceil(),
                    (index) {
                      final startIndex = index * columns;
                      final endIndex = startIndex + columns;
                      final pagePlaylists =
                          widget.playlists.sublist(startIndex, endIndex);
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: columns,
                          children: pagePlaylists
                              .map((playlist) => _buildPlaylistItem(playlist))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaylistsForMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 0.8),
          // Apply padding only to the text
          child: Row(
            children: [
              Text(
                'Swipe to Discover Your Mood.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(width: 8.0), // Add space between text and icon
              Icon(Icons.swipe, size: 16.0), // Arrow icon
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 410.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                (widget.playlists.length / 4).ceil(),
                (index) {
                  final startIndex = index * 4;
                  final endIndex = startIndex + 4;
                  final pagePlaylists =
                      widget.playlists.sublist(startIndex, endIndex);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: pagePlaylists
                          .map((playlist) => _buildPlaylistItem(playlist))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistItem(Map<String, dynamic> playlist,
      {double? itemWidth}) {
    return GestureDetector(
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
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding between images
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            playlist['image'] ?? 'https://via.placeholder.com/200',
            fit: BoxFit.cover,
            width: itemWidth ?? 60.0,
            height: itemWidth ?? 60.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              10.0, 2.0, 0.0, 0), // Apply padding only to the text
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 250.0, // Adjust container height if needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildAlbumListItem(data[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumListItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumScreen(
              albumId: item['id'] ?? 'Unknown',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 200.0, // Increased container width to accommodate larger images
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Reduced border radius
              child: Image.network(
                item['image'] ?? 'https://via.placeholder.com/200',
                fit: BoxFit.cover,
                height: 200.0, // Increased image height
                width: 200.0, // Increased image width
              ),
            ),
            const SizedBox(height: 8.0), // Gap between image and text
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  item['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0, // Increased text size
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingAlbumItem(Map<String, dynamic> album) {
    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        width: 200.0, // Increased container width to accommodate larger images
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Reduced border radius
              child: Image.network(
                album['image'] ?? 'https://via.placeholder.com/200',
                fit: BoxFit.cover,
                height: 200.0, // Increased image height
                width: 200.0, // Increased image width
              ),
            ),
            const SizedBox(height: 8.0), // Gap between image and text
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0, // Increased text size
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                      height: 4.0), // Small gap between title and song count
                  Row(
                    children: [
                      const Icon(Icons.music_note,
                          size: 16.0, color: Colors.grey),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          '${album['songCount'] ?? 0} Song(s)',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
