import 'api_service.dart'; // Import your APIService class

final apiService = APIService();
Map<String, dynamic>? cachedData; // Cache to store fetched data

// Function to fetch data if not already fetched
Future<Map<String, dynamic>> fetchDataIfNeeded() async {
  if (cachedData == null) {
    cachedData = await apiService.fetchData(['hindi']);
  }
  return cachedData!;
}

// Function to fetch and return album info
Future<List<Map<String, dynamic>>> fetchAlbumInfo() async {
  try {
    final data = await fetchDataIfNeeded(); // Pass the desired language
    final albums = data['data']['albums']; // Get the list of albums
    List<Map<String, dynamic>> albumInfoList = [];
    if (albums != null && albums.isNotEmpty) {
      for (final album in albums) {
        // Extract album info
        final Map<String, dynamic> albumInfo = {
          'id': album['id'],
          'name': album['name'],
          'year': album['year'],
          'type': album['type'],
          'playCount': album['playCount'],
          'language': album['language'],
          'explicitContent': album['explicitContent'],
          'songCount': album['songCount'],
          'url': album['url'],
          'artists': album['artists'],
          'image': album['image'][2]['link'],
          'songs': album['songs'],
        };
        albumInfoList.add(albumInfo);
      }
    }
    return albumInfoList;
  } catch (e) {
    throw e;
  }
}

// Function to fetch and return playlist info
Future<List<Map<String, dynamic>>> fetchPlaylistInfo() async {
  try {
    final data = await fetchDataIfNeeded(); // Pass the desired language
    final playlists = data['data']['playlists']; // Get the list of playlists
    List<Map<String, dynamic>> playlistInfoList = [];
    if (playlists != null && playlists.isNotEmpty) {
      for (final playlist in playlists) {
        // Extract playlist info
        final Map<String, dynamic> playlistInfo = {
          'id': playlist['id'],
          'userId': playlist['userId'],
          'name': playlist['title'],
          'subtitle': playlist['subtitle'],
          'type': playlist['type'],
          'songCount': playlist['songCount'],
          'url': playlist['url'],
          'firstname': playlist['firstname'],
          'followerCount': playlist['followerCount'],
          'lastUpdated': playlist['lastUpdated'],
          'explicitContent': playlist['explicitContent'],
          'image': playlist['image'][2]['link'],
        };
        playlistInfoList.add(playlistInfo);
      }
    }
    return playlistInfoList;
  } catch (e) {
    throw e;
  }
}

// Function to fetch and return charts info
Future<List<Map<String, dynamic>>> fetchChartsInfo() async {
  try {
    final data = await fetchDataIfNeeded(); // Pass the desired language
    final charts = data['data']['charts']; // Get the list of charts
    List<Map<String, dynamic>> chartInfoList = [];
    print(charts);
    if (charts != null && charts.isNotEmpty) {
      for (final chart in charts) {
        // Extract chart info
        final Map<String, dynamic> chartInfo = {
          'id': chart['id'],
          'name': chart['title'],
          'subtitle': chart['subtitle'],
          'type': chart['type'],
          'songCount': chart['songCount'],
          'url': chart['url'],
          'firstname': chart['firstname'],
          'explicitContent': chart['explicitContent'],
          'language': chart['language'],
          'image': chart['image'][2]['link'],
        };
        chartInfoList.add(chartInfo);
      }
    }
    return chartInfoList;
  } catch (e) {
    throw e;
  }
}

// Function to fetch and return trending songs info
Future<List<Map<String, dynamic>>> fetchTrendingSongsInfo() async {
  try {
    final data = await fetchDataIfNeeded(); // Pass the desired language
    final trendingSongs =
        data['data']['trending']['songs']; // Get the list of trending songs
    List<Map<String, dynamic>> songInfoList = [];
    if (trendingSongs != null && trendingSongs.isNotEmpty) {
      for (final song in trendingSongs) {
        // Extract song info
        final Map<String, dynamic> songInfo = {
          'id': song['id'],
          'name': song['name'],
          'type': song['type'],
          'album': song['album'],
          'year': song['year'],
          'releaseDate': song['releaseDate'],
          'duration': song['duration'],
          'label': song['label'],
          'explicitContent': song['explicitContent'],
          'playCount': song['playCount'],
          'language': song['language'],
          'url': song['url'],
          'image': song['image'][2]['link'],
          'primaryArtists': song['primaryArtists'],
        };
        songInfoList.add(songInfo);
      }
    }
    return songInfoList;
  } catch (e) {
    throw e;
  }
}

// Function to fetch and return trending albums info
Future<List<Map<String, dynamic>>> fetchTrendingAlbumsInfo() async {
  try {
    final data = await fetchDataIfNeeded(); // Pass the desired language
    final trendingAlbums =
        data['data']['trending']['albums']; // Get the list of trending albums
    List<Map<String, dynamic>> albumInfoList = [];
    if (trendingAlbums != null && trendingAlbums.isNotEmpty) {
      for (final album in trendingAlbums) {
        // Extract album info
        final Map<String, dynamic> albumInfo = {
          'id': album['id'],
          'name': album['name'],
          'type': album['type'],
          'year': album['year'],
          'releaseDate': album['releaseDate'],
          'language': album['language'],
          'explicitContent': album['explicitContent'],
          'songCount': album['songCount'],
          'url': album['url'],
          'image': album['image'][2]['link'],
          'artists': album['artists'],
        };
        albumInfoList.add(albumInfo);
      }
    }
    return albumInfoList;
  } catch (e) {
    throw e;
  }
}
