import 'package:flutter/material.dart';
import 'artist_info.dart';
import 'album_screen.dart'; // Import the AlbumScreen
import 'audio_player_service.dart';

class ArtistScreen extends StatefulWidget {
  final String artistId;

  ArtistScreen({required this.artistId});

  @override
  _ArtistScreenState createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  Future<ArtistInfo?>? _artistInfoFuture;
  AudioPlayerService _audioPlayerService = AudioPlayerService();
  @override
  void initState() {
    super.initState();
    _artistInfoFuture = fetchArtistInfo(widget.artistId);
  }

  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String minutes = (duration.inMinutes).toString().padLeft(2, '0');
    String remainingSeconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String _getArtistsText(artists) {
    if (artists.length > 3) {
      return '${artists.sublist(0, 3).map((artist) => artist.name).join(", ")} and more';
    } else {
      return artists.map((artist) => artist.name).join(", ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<ArtistInfo?>(
        future: _artistInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          } else {
            final artistInfo = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildArtistInfo(artistInfo),
                  _buildSectionTitle('Top Picks from Artist'),
                  _buildTopSongs(artistInfo),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Top Albums'),
                  _buildTopAlbums(artistInfo),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Singles'),
                  _buildSingles(artistInfo),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildArtistImage(double screenWidth, String imageUrl) {
    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: screenWidth,
            height: screenWidth,
            fit: BoxFit.cover,
          )
        : Container();
  }

  Widget _buildArtistInfo(ArtistInfo artistInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildArtistImageSmall(artistInfo.imageUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistInfo.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      artistInfo.type,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            artistInfo.bio,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistImageSmall(String imageUrl) {
    return imageUrl.isNotEmpty
        ? ClipRRect(
            borderRadius:
                BorderRadius.circular(8.0), // Adjust the radius as needed
            child: Image.network(
              imageUrl,
              width: 120, // Increase the width
              height: 120, // Increase the height
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey, // Optionally add a placeholder color
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
  }

  Widget _buildTopSongs(ArtistInfo artistInfo) {
    return Column(
      children: artistInfo.topSongs.map((song) {
        return GestureDetector(
          onTap: () {
            _audioPlayerService.addToPlaylist(song.id);
          },
          child: Container(
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              leading: _buildSongImage(song.imageUrl),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getArtistsText(song.artists),
                    style: const TextStyle(
                        fontSize: 13, color: Color.fromARGB(255, 43, 43, 43)),
                  ),
                ],
              ),
              trailing: Text(
                _formatDuration(song.duration),
                style: const TextStyle(
                    fontSize: 13, color: Color.fromARGB(255, 43, 43, 43)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSongImage(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20),
        ));
  }

  Widget _buildTopAlbums(ArtistInfo artistInfo) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      children: artistInfo.topAlbums.map((album) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumScreen(albumId: album.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            child: Image.network(
              album.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingles(ArtistInfo artistInfo) {
    return Column(
      children: artistInfo.singles.map((single) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumScreen(
                  albumId: single.id,
                ),
              ),
            );
          },
          child: Container(
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              leading: single.imageUrl.isNotEmpty
                  ? Image.network(
                      single.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : null,
              title: Text(
                single.name,
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                _getArtistsText(single.artists),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
