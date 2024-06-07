import 'package:flutter/material.dart';
import 'artist_screen.dart';
import 'api_service.dart'; // Import your APIService and AlbumService classes here
import 'fetch_album_info.dart';
import 'data_model.dart';
import 'audio_player_service.dart';

class AlbumScreen extends StatefulWidget {
  final String albumId;

  const AlbumScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  late Future<AlbumDetails> _albumDetailsFuture;
  late AlbumService _albumService;

  @override
  void initState() {
    super.initState();
    _albumService = AlbumService(APIService());
    _albumDetailsFuture = _albumService.fetchAlbumDetails(widget.albumId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<AlbumDetails>(
        future: _albumDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final albumDetails = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
              children: [
                _buildAlbumInfo(albumDetails.albumInfo),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                  child: Text(
                    "Artists",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
                _buildArtistsSlider(albumDetails.artistsInfo),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                  child: Text(
                    "Songs",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
                _buildSongsList(albumDetails.songsInfo),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSongsList(List<SongInfo> songs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: songs.map((song) {
        int minutes = (song.duration ~/ 60);
        int seconds = (song.duration % 60);

        return GestureDetector(
          onTap: () {
            // Call your method here, passing the song information if needed
            // Example: playSong(song);
            _audioPlayerService.addToPlaylist(song.id);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    song.images.isNotEmpty
                        ? song.images.last['url']
                        : 'https://via.placeholder.com/150',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.name,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildPlayCountIcon(song.playCount),
                    ],
                  ),
                ),
                Text(
                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 43, 118),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayCountIcon(int playCount) {
    IconData icon;
    Color color;
    if (playCount < 1000) {
      icon = Icons.play_circle_outline;
      color = Colors.grey;
    } else if (playCount < 5000) {
      icon = Icons.play_circle_filled;
      color = Colors.red;
    } else if (playCount < 10000) {
      icon = Icons.play_arrow;
      color = Colors.grey;
    } else {
      icon = Icons.fast_forward;
      color = Colors.yellow;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$playCount',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.contain,
        ),
      ),
      height: 300,
      width: 300,
    );
  }

  Widget _buildAlbumInfo(AlbumInfo albumInfo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Image
          SizedBox(
            width: 150,
            height: 150,
            child: _buildAlbumImage(albumInfo.images.last['url']),
          ),
          const SizedBox(
              width: 20), // Add some spacing between the image and text
          // Title and Song Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  albumInfo.name,
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                const SizedBox(
                    height:
                        8), // Add some spacing between the title and song count
                Text(
                  '${albumInfo.songCount} Song(s)',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsSlider(List<ArtistInfo> artists) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          return GestureDetector(
            onTap: () {
              // Call your method here, passing the artist information if needed
              // Example: viewArtistDetails(artist);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistScreen(artistId: artist.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      artist.images.isNotEmpty
                          ? artist.images.last['url']
                          : 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
