import 'api_service.dart';
import 'data_model.dart';

class AlbumService {
  final APIService _apiService;

  AlbumService(this._apiService);

  Future<AlbumDetails> fetchAlbumDetails(String videoId) async {
    try {
      Map<String, dynamic> albumData =
          await _apiService.fetchAlbumData(videoId);

      // Extracting album data
      Map<String, dynamic> album = albumData['data'];
      List<dynamic> songs = album['songs'];
      List<dynamic> artists = album['artists']['all'];

      // Album Info
      AlbumInfo albumInfo = AlbumInfo(
        name: album['name'],
        year: album['year'],
        description: album['description'],
        language: album['language'],
        url: album['url'],
        songCount: album['songCount'],
        images: album['image'],
        artists: artists,
        songs: songs,
      );

      // Artists Info
      List<ArtistInfo> artistsInfo = artists.map((artist) {
        return ArtistInfo(
          name: artist['name'],
          id: artist['id'],
          url: artist['url'],
          images: artist['image'],
        );
      }).toList();

      // Songs Info
      List<SongInfo> songsInfo = songs.map((song) {
        return SongInfo(
          id: song['id'],
          name: song['name'],
          duration: song['duration'],
          language: song['language'],
          url: song['url'],
          copyright: song['copyright'],
          playCount: song['playCount'],
          hasLyrics: song['hasLyrics'],
          downloadUrls: song['downloadUrl'],
          images: song['image'],
        );
      }).toList();

      return AlbumDetails(
        albumInfo: albumInfo,
        artistsInfo: artistsInfo,
        songsInfo: songsInfo,
      );
    } catch (e) {
      throw e;
    }
  }
}
