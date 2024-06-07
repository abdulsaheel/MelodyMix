import 'package:flutter/material.dart';
import 'Audioplayer_Screen.dart'; // Import the full-screen player screen
import 'audio_player_service.dart'; // Import the audio player service
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayerWidget extends StatefulWidget {
  @override
  _MiniPlayerWidgetState createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  late AudioPlayerService _audioPlayerService;
  late bool _isPlaying;
  late Duration _elapsedDuration;

  @override
  void initState() {
    super.initState();
    _audioPlayerService = AudioPlayerService();
    _isPlaying = false;
    _elapsedDuration = Duration.zero;

    // Listen to changes in the playback state
    _audioPlayerService.player.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState?.playing ?? false;
      });
    });

    // Listen to changes in the playback position
    _audioPlayerService.player.positionStream.listen((position) {
      setState(() {
        _elapsedDuration = position ?? Duration.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const AudioPlayerScreen(), // Navigate to full-screen player
          ),
        );
      },
      child: StreamBuilder<SequenceState?>(
        stream: _audioPlayerService.player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.currentSource == null) {
            return Container(); // Hide mini player if no song is playing
          }
          final mediaItem = state!.currentSource!.tag as MediaItem;
          final totalDuration =
              _audioPlayerService.player.duration ?? Duration.zero;
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(mediaItem.artUri.toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mediaItem.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mediaItem.artist ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.black),
                  onPressed: () {
                    _audioPlayerService.player.seekToPrevious();
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayerService.player.pause();
                    } else {
                      _audioPlayerService.player.play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.black),
                  onPressed: () {
                    _audioPlayerService.player.seekToNext();
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  '${_formatDuration(_elapsedDuration)} / ${_formatDuration(totalDuration)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
