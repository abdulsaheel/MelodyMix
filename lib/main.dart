import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'AudioPlayer_screen.dart';
import 'splash_screen.dart'; // Import the splash screen

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yourcompany.yourapp.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Mix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Show SplashScreen initially
      routes: {
        '/audio_screen': (context) =>
            const AudioPlayerScreen(), // Register AudioScreen route
      },
    );
  }
}
