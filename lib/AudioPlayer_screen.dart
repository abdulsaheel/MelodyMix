import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'audio_player_service.dart';
import 'common.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({Key? key}) : super(key: key);

  @override
  AudioPlayerScreenState createState() => AudioPlayerScreenState();
}

class AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  @override
  void initState() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Adjust rotation speed as needed
    );
    _audioPlayerService.player.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _rotationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<SequenceState?>(
                  stream: _audioPlayerService.player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.currentSource == null) {
                      return const Text(
                        "No song playing",
                        style: TextStyle(color: Colors.black54),
                      );
                    }
                    final mediaItem = state!.currentSource!.tag as MediaItem;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * 3.14,
                              child: ClipOval(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        mediaItem.artUri.toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          mediaItem.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mediaItem.artist ?? '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                StreamBuilder<Duration>(
                  stream: _audioPlayerService.player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration =
                        _audioPlayerService.player.duration ?? Duration.zero;
                    final bufferedPosition =
                        _audioPlayerService.player.bufferedPosition;
                    return Column(
                      children: [
                        SeekBar(
                          bufferedPosition: bufferedPosition,
                          duration: duration,
                          position: position,
                          onChangeEnd: (newPosition) {
                            _audioPlayerService.player.seek(newPosition);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.black),
                      onPressed: () {
                        showSliderDialog(
                          context: context,
                          title: "Adjust volume",
                          divisions: 10,
                          min: 0.0,
                          max: 1.0,
                          value: _audioPlayerService.player.volume,
                          stream: _audioPlayerService.player.volumeStream,
                          onChanged: _audioPlayerService.player.setVolume,
                        );
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.black),
                      iconSize: 64,
                      onPressed: _audioPlayerService.player.hasPrevious
                          ? _audioPlayerService.player.seekToPrevious
                          : null,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayerService.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        return IconButton(
                          icon: Icon(
                            playerState?.playing ?? false
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.black,
                          ),
                          iconSize: 64,
                          onPressed: () {
                            if (_audioPlayerService.player.playing) {
                              _audioPlayerService.player.pause();
                            } else {
                              _audioPlayerService.player.play();
                            }
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.black),
                      iconSize: 64,
                      onPressed: _audioPlayerService.player.hasNext
                          ? _audioPlayerService.player.seekToNext
                          : null,
                    ),
                    StreamBuilder<double>(
                      stream: _audioPlayerService.player.speedStream,
                      builder: (context, snapshot) => IconButton(
                        icon: Text(
                          "${snapshot.data?.toStringAsFixed(1)}x",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          showSliderDialog(
                            context: context,
                            title: "Adjust speed",
                            divisions: 10,
                            min: 0.5,
                            max: 1.5,
                            value: _audioPlayerService.player.speed,
                            stream: _audioPlayerService.player.speedStream,
                            onChanged: _audioPlayerService.player.setSpeed,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<LoopMode>(
                      stream: _audioPlayerService.player.loopModeStream,
                      builder: (context, snapshot) {
                        final loopMode = snapshot.data ?? LoopMode.off;
                        final icon = loopMode == LoopMode.off
                            ? Icons.repeat
                            : loopMode == LoopMode.one
                                ? Icons.repeat_one
                                : Icons.repeat;
                        return IconButton(
                          icon: Icon(icon, color: Colors.black),
                          onPressed: () {
                            _audioPlayerService.toggleLoopMode();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'You might also like',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StreamBuilder<SequenceState?>(
                        stream: _audioPlayerService.player.sequenceStateStream,
                        builder: (context, snapshot) {
                          final state = snapshot.data;
                          final sequence = state?.sequence ?? [];
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sequence.length,
                            itemBuilder: (context, index) {
                              final mediaItem =
                                  sequence[index].tag as MediaItem;
                              return ListTile(
                                leading: mediaItem.artUri != null
                                    ? Image.network(
                                        mediaItem.artUri.toString(),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(
                                        width: 50,
                                        height: 50,
                                      ),
                                title: Text(
                                  mediaItem.title,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                subtitle: Text(
                                  mediaItem.artist ?? '',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                onTap: () {
                                  _audioPlayerService.player
                                      .seek(Duration.zero, index: index);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
