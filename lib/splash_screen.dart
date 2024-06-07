import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_page.dart';
import 'fetch_song_info.dart'; // Import your data fetching methods

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
    _navigateToHome();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch your data here
      await fetchTrendingSongsInfo();
      await fetchTrendingAlbumsInfo();
      await fetchAlbumInfo();
      await fetchPlaylistInfo();
    } catch (e) {
      print("Error fetching data: $e");
      // Handle error
    }
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(
        seconds: 3)); // Ensure the animation plays for at least 3 seconds

    // Wait for data to be fetched before navigating
    await _dataFuture;

    // Navigate to MyHomePage with the fetched data
    List<Map<String, dynamic>> trendingSongs = await fetchTrendingSongsInfo();
    List<Map<String, dynamic>> trendingAlbums = await fetchTrendingAlbumsInfo();
    List<Map<String, dynamic>> albums = await fetchAlbumInfo();
    List<Map<String, dynamic>> playlists = await fetchPlaylistInfo();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          trendingSongs: trendingSongs,
          trendingAlbums: trendingAlbums,
          albums: albums,
          playlists: playlists,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/splash.json'),
      ),
    );
  }
}
