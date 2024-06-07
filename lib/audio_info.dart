class SongInfo {
  String id;
  String name;
  String type;
  String year;
  String releaseDate;
  int duration;
  String label;
  bool explicitContent;
  int playCount;
  String language;
  bool hasLyrics;
  String url;
  String copyright;
  AlbumInfo album;
  List<ArtistInfo> artists;
  List<ImageInfo> images;
  List<DownloadUrlInfo> downloadUrls;

  SongInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.releaseDate,
    required this.duration,
    required this.label,
    required this.explicitContent,
    required this.playCount,
    required this.language,
    required this.hasLyrics,
    required this.url,
    required this.copyright,
    required this.album,
    required this.artists,
    required this.images,
    required this.downloadUrls,
  });
}

class AlbumInfo {
  String id;
  String name;
  String url;

  AlbumInfo({required this.id, required this.name, required this.url});
}

class ArtistInfo {
  String id;
  String name;
  String role;
  String url;

  ArtistInfo(
      {required this.id,
      required this.name,
      required this.role,
      required this.url});
}

class ImageInfo {
  String quality;
  String url;

  ImageInfo({required this.quality, required this.url});
}

class DownloadUrlInfo {
  String quality;
  String url;

  DownloadUrlInfo({required this.quality, required this.url});
}

SongInfo parseSongInfo(Map<String, dynamic> songInfo) {
  AlbumInfo albumInfo = AlbumInfo(
    id: songInfo['data'][0]['album']['id'],
    name: songInfo['data'][0]['album']['name'],
    url: songInfo['data'][0]['album']['url'],
  );

  List<ArtistInfo> artistsInfo = [];
  for (var artist in songInfo['data'][0]['artists']['primary']) {
    artistsInfo.add(ArtistInfo(
      id: artist['id'],
      name: artist['name'],
      role: artist['role'],
      url: artist['url'],
    ));
  }

  List<ImageInfo> imagesInfo = [];
  for (var image in songInfo['data'][0]['image']) {
    imagesInfo.add(ImageInfo(
      quality: image['quality'],
      url: image['url'],
    ));
  }

  List<DownloadUrlInfo> downloadUrlsInfo = [];
  for (var downloadUrl in songInfo['data'][0]['downloadUrl']) {
    downloadUrlsInfo.add(DownloadUrlInfo(
      quality: downloadUrl['quality'],
      url: downloadUrl['url'],
    ));
  }

  return SongInfo(
    id: songInfo['data'][0]['id'],
    name: songInfo['data'][0]['name'],
    type: songInfo['data'][0]['type'],
    year: songInfo['data'][0]['year'],
    releaseDate: songInfo['data'][0]['releaseDate'],
    duration: songInfo['data'][0]['duration'],
    label: songInfo['data'][0]['label'],
    explicitContent: songInfo['data'][0]['explicitContent'],
    playCount: songInfo['data'][0]['playCount'],
    language: songInfo['data'][0]['language'],
    hasLyrics: songInfo['data'][0]['hasLyrics'],
    url: songInfo['data'][0]['url'],
    copyright: songInfo['data'][0]['copyright'],
    album: albumInfo,
    artists: artistsInfo,
    images: imagesInfo,
    downloadUrls: downloadUrlsInfo,
  );
}
