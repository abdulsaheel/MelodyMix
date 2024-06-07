import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audio_info.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  late AudioPlayer _player;
  late ConcatenatingAudioSource _playlist;

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal() {
    _player = AudioPlayer();
    _playlist = ConcatenatingAudioSource(children: []);
    _init();
  }

  AudioPlayer get player => _player;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(_playlist,
          preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux);
    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
    }
    _player.positionDiscontinuityStream.listen((discontinuity) {
      if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
        _showItemFinished(discontinuity.previousEvent.currentIndex);
      }
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _showItemFinished(_player.currentIndex);
      }
    });
  }

  Future<dynamic> _fetchSongInfo(String songId) async {
    final url = Uri.parse('https://saavn.dev/api/songs/$songId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final songInfoJson = json.decode(response.body);
        final fetchedSongInfo = parseSongInfo(songInfoJson);
        return fetchedSongInfo;
      }
    } catch (e) {
      print('Error fetching song info: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSongSuggestions(String id) async {
    final String url = 'https://saavn.dev/api/songs/$id/suggestions';
    List<Map<String, dynamic>> suggestionsList = [];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List suggestions = data['data'];
          for (var suggestion in suggestions) {
            Map<String, dynamic> suggestionInfo = {
              'ID': suggestion['id'],
              'Name': suggestion['name'],
              'Type': suggestion['type'],
              'Year': suggestion['year'],
              'Release Date': suggestion['releaseDate'],
              'Duration': suggestion['duration'],
              'Label': suggestion['label'],
              'Explicit Content': suggestion['explicitContent'],
              'Play Count': suggestion['playCount'],
              'Language': suggestion['language'],
              'Has Lyrics': suggestion['hasLyrics'],
              'Lyrics ID': suggestion['lyricsId'],
              'URL': suggestion['url'],
              'Copyright': suggestion['copyright'],
              'Album': {
                'Album ID': suggestion['album']['id'],
                'Album Name': suggestion['album']['name'],
                'Album URL': suggestion['album']['url'],
              },
              'Primary Artists': suggestion['artists']['primary']
                  .map((artist) => {
                        'Artist ID': artist['id'],
                        'Artist Name': artist['name'],
                        'Role': artist['role'],
                        'Images': artist['image']
                            .map((image) => {
                                  'Image Quality': image['quality'],
                                  'Image URL': image['url'],
                                })
                            .toList(),
                      })
                  .toList(),
              'Featured Artists': suggestion['artists']['featured']
                  .map((artist) => {
                        'Artist ID': artist['id'],
                        'Artist Name': artist['name'],
                        'Role': artist['role'],
                        'Images': artist['image']
                            .map((image) => {
                                  'Image Quality': image['quality'],
                                  'Image URL': image['url'],
                                })
                            .toList(),
                      })
                  .toList(),
              'All Artists': suggestion['artists']['all']
                  .map((artist) => {
                        'Artist ID': artist['id'],
                        'Artist Name': artist['name'],
                        'Role': artist['role'],
                        'Images': artist['image']
                            .map((image) => {
                                  'Image Quality': image['quality'],
                                  'Image URL': image['url'],
                                })
                            .toList(),
                      })
                  .toList(),
              'Images': suggestion['image']
                  .map((image) => {
                        'Image Quality': image['quality'],
                        'Image URL': image['url'],
                      })
                  .toList(),
              'Download URLs': suggestion['downloadUrl']
                  .map((downloadUrl) => {
                        'Quality': downloadUrl['quality'],
                        'URL': downloadUrl['url'],
                      })
                  .toList(),
            };
            suggestionsList.add(suggestionInfo);
          }
        } else {
          throw Exception('Failed to get song suggestions: ${data['error']}');
        }
      } else {
        throw Exception(
            'Failed to load suggestions: ${response.statusCode}- ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
    return suggestionsList;
  }

  void toggleLoopMode() {
    final currentLoopMode = player.loopMode;
    if (currentLoopMode == LoopMode.off) {
      player.setLoopMode(LoopMode.all);
    } else if (currentLoopMode == LoopMode.all) {
      player.setLoopMode(LoopMode.one);
    } else {
      player.setLoopMode(LoopMode.off);
    }
  }

  Future<void> addToPlaylist(String id) async {
    final songInfo = await _fetchSongInfo(id);
    print('Fetched Song Info: $songInfo');
    final suggestions = await _fetchSongSuggestions(id);
    print('Fetched Song Suggestions: $suggestions');

    List<AudioSource> playlistItems = [];

    if (songInfo != null) {
      playlistItems.add(
        AudioSource.uri(
          Uri.parse(songInfo.downloadUrls.last.url),
          tag: MediaItem(
            id: songInfo.id,
            title: songInfo.name,
            album: songInfo.album.name,
            artist: songInfo.artists.isNotEmpty
                ? songInfo.artists.map((artist) => artist.name).join(', ')
                : "",
            artUri: Uri.parse(songInfo.images.last.url),
          ),
        ),
      );
    }

    for (var suggestion in suggestions) {
      try {
        var audioSource = AudioSource.uri(
          Uri.parse(suggestion['Download URLs'].last['URL']),
          tag: MediaItem(
            id: suggestion['ID'],
            title: suggestion['Name'],
            album: suggestion['Album']['Album Name'],
            artist: suggestion['Primary Artists'].isNotEmpty
                ? suggestion['Primary Artists']
                    .map((artist) => artist['Artist Name'])
                    .join(', ')
                : "",
            artUri: Uri.parse(suggestion['Images'].last['Image URL']),
          ),
        );
        playlistItems.add(audioSource);
      } catch (e) {
        print("Error adding song to playlist: $e");
      }
    }

    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: playlistItems,
    );

    try {
      await _player.setAudioSource(_playlist,
          preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux);
      _player.play();
    } on PlayerException catch (e) {
      print("Error setting audio source: $e");
    } on PlayerInterruptedException catch (e) {
      print("Audio playback interrupted: $e");
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void _showItemFinished(int? index) {
    if (index != null) {
      final item = _playlist.children[index] as UriAudioSource;
      final mediaItem = item.tag as MediaItem;
      print("Finished playing ${mediaItem.title}");
    }
  }
}
