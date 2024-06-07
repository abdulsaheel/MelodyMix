class Album {
  final String id;
  final String name;
  final String type;
  final String language;
  final bool explicitContent;
  final int songCount;
  final String url;
  final List<Artist> artists;
  final List<dynamic> image;
  final List<Song> songs;

  Album({
    required this.id,
    required this.name,
    required this.type,
    required this.language,
    required this.explicitContent,
    required this.songCount,
    required this.url,
    required this.artists,
    required this.image,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var artistsList = json['artists']['primary'] as List;
    List<Artist> artists = artistsList.map((i) => Artist.fromJson(i)).toList();

    var songsList = json['songs'] as List;
    List<Song> songs = songsList.map((i) => Song.fromJson(i)).toList();

    return Album(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      language: json['language'],
      explicitContent: json['explicitContent'],
      songCount: json['songCount'],
      url: json['url'],
      artists: artists,
      image: json['image'],
      songs: songs,
    );
  }
}

class Artist {
  final String id;
  final String name;
  final String url;
  final List<dynamic> image;
  final String type;
  final String role;

  Artist({
    required this.id,
    required this.name,
    required this.url,
    required this.image,
    required this.type,
    required this.role,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'].toString(),
      name: json['name'],
      url: json['url'],
      image: json['image'],
      type: json['type'],
      role: json['role'],
    );
  }
}

class Song {
  final String id;
  final String name;
  final String type;
  final String year;
  final String releaseDate;
  final int duration;
  final String label;
  final bool explicitContent;
  final int playCount;
  final String language;
  final String url;
  final List<dynamic> image;

  Song({
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
    required this.url,
    required this.image,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      year: json['year'],
      releaseDate: json['releaseDate'],
      duration: json['duration'],
      label: json['label'],
      explicitContent: json['explicitContent'],
      playCount: json['playCount'],
      language: json['language'],
      url: json['url'],
      image: json['image'],
    );
  }
}

class Playlist {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final List<dynamic> image;
  final String url;
  final int songCount;
  final String firstname;
  final int followerCount;
  final String lastUpdated;
  final bool explicitContent;

  Playlist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.url,
    required this.songCount,
    required this.firstname,
    required this.followerCount,
    required this.lastUpdated,
    required this.explicitContent,
  });
}

class Chart {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final List<dynamic> image;
  final String url;
  final String firstname;
  final bool explicitContent;
  final String language;

  Chart({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.url,
    required this.firstname,
    required this.explicitContent,
    required this.language,
  });
}

class Trending {
  final List<Song> songs;

  Trending({required this.songs});
}

// album data_models

class AlbumInfo {
  final String name;
  final int year;
  final String description;
  final String language;
  final String url;
  final int songCount;
  final List<dynamic> images;
  final List<dynamic> artists;
  final List<dynamic> songs;

  AlbumInfo({
    required this.name,
    required this.year,
    required this.description,
    required this.language,
    required this.url,
    required this.songCount,
    required this.images,
    required this.artists,
    required this.songs,
  });
}

class ArtistInfo {
  final String name;
  final String id;
  final String url;
  final List<dynamic> images;

  ArtistInfo({
    required this.name,
    required this.id,
    required this.url,
    required this.images,
  });
}

class SongInfo {
  final String id;

  final String name;
  final int duration;
  final String language;
  final String url;
  final String copyright;
  final int playCount;
  final bool hasLyrics;
  final List<dynamic> downloadUrls;
  final List<dynamic> images;
  // final String Imageurl;

  SongInfo({
    required this.id,
    required this.name,
    required this.duration,
    required this.language,
    required this.url,
    required this.copyright,
    required this.playCount,
    required this.hasLyrics,
    required this.downloadUrls,
    required this.images,
  });
}

class AlbumDetails {
  final AlbumInfo albumInfo;
  final List<ArtistInfo> artistsInfo;
  final List<SongInfo> songsInfo;

  AlbumDetails({
    required this.albumInfo,
    required this.artistsInfo,
    required this.songsInfo,
  });
}

class PlaylistSong {
  final String id;
  final String name;
  final String type;
  final String year;
  final String releaseDate;
  final int duration;
  final String label;
  final bool explicitContent;
  final int playCount;
  final String language;
  final bool hasLyrics;
  final dynamic lyricsId;
  final String url;
  final dynamic copyright;
  final PlaylistAlbum album;
  final List<PlaylistArtistInfo> artists;
  final List<Map<String, String>> image;
  final List<Map<String, String>> downloadUrl;

  PlaylistSong({
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
    required this.lyricsId,
    required this.url,
    required this.copyright,
    required this.album,
    required this.artists,
    required this.image,
    required this.downloadUrl,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) {
    return PlaylistSong(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      year: json['year'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      duration: json['duration'] ?? 0,
      label: json['label'] ?? '',
      explicitContent: json['explicitContent'] ?? false,
      playCount: json['playCount'] ?? 0,
      language: json['language'] ?? '',
      hasLyrics: json['hasLyrics'] ?? false,
      lyricsId: json['lyricsId'],
      url: json['url'] ?? '',
      copyright: json['copyright'],
      album: PlaylistAlbum.fromJson(json['album']),
      artists: (json['artists'] as List<dynamic>)
          .map((artist) => PlaylistArtistInfo.fromJson(artist))
          .toList(),
      image: List<Map<String, String>>.from(json['image'] ?? []),
      downloadUrl: List<Map<String, String>>.from(json['downloadUrl'] ?? []),
    );
  }
}

class PlaylistAlbum {
  final String id;
  final String name;
  final String url;

  PlaylistAlbum({
    required this.id,
    required this.name,
    required this.url,
  });

  factory PlaylistAlbum.fromJson(Map<String, dynamic> json) {
    return PlaylistAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PlaylistArtistInfo {
  final String id;
  final String name;
  final String role;
  final List<Map<String, String>> images;
  final String type;
  final String url;

  PlaylistArtistInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.images,
    required this.type,
    required this.url,
  });

  factory PlaylistArtistInfo.fromJson(Map<String, dynamic> json) {
    return PlaylistArtistInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      images: List<Map<String, String>>.from(json['image'] ?? []),
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
