## Melody Mix Music Player App

This Flutter application allows users to explore and play music from the Saavn platform. It utilizes the [Unofficial JioSaavn API](https://github.com/sumitkolhe/jiosaavn-api) to fetch music data including songs, albums, artists, and playlists.

### Features

- **Search**: Users can search for songs, albums, artists, and playlists.
- **Playlists**: View and play playlists.
- **Albums**: Explore albums and play songs from them.
- **Artists**: Discover artists and their music.
- **Mini Player**: A mini player widget is available for quick access to play, pause, and skip tracks.
- **Full-Screen Player**: Navigate to a full-screen player for a more immersive music experience.
- **Background Audio**: Enjoy continuous playback while using other apps with background audio support.

### Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/abdulsaheel/MelodyMix.git
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

### Dependencies

- `http`: For making HTTP requests to the JioSaavn API.
- `just_audio`: Provides audio playback capabilities.
- `just_audio_background`: Allows background audio playback.
- `flutter/material.dart`: Flutter material design widgets.

### Download the App

#### Currently, Windows and Android builds are available for download:

<a href="https://github.com/abdulsaheel/MelodyMix/releases/download/v0.0.1/MelodyMix-Windows-Installer.exe" target="_blank">
  <img src="https://img.shields.io/badge/Download-Windows-blue?style=for-the-badge&logo=windows" alt="Download Windows">
</a>
<a href="https://github.com/abdulsaheel/MelodyMix/releases/download/v0.0.1/Melody.Mix.v0.0.1.apk" target="_blank">
  <img src="https://img.shields.io/badge/Download-Android-green?style=for-the-badge&logo=android" alt="Download Android">
</a>

### Get it on GitHub

<a href="https://github.com/abdulsaheel/MelodyMix/releases" target="_blank">
  <img src="https://img.shields.io/badge/Get%20It%20From-GitHub-lightgrey?style=for-the-badge&logo=github" alt="Get It From GitHub">
</a>

### Todos

- [ ] Implement user authentication and account management.
- [ ] Add support for creating and managing playlists.
- [ ] Enhance search functionality with suggestions and filters.
- [ ] Improve the structure of the codebase by arranging it into models, services, and UI components.
- [ ] Remove redundant models for data.
- [ ] Add an option to play all songs in playlists and albums.
- [ ] Enhance the player UI with album art, song progress, and controls.
- [ ] Implement offline mode for downloading and playing music offline.
- [ ] Implement Home Screen Widget with Playback Controls.

### Disclaimer

This application is for educational purposes only. It neither promotes nor endorses the unauthorized usage of the JioSaavn API. The developer holds zero liability for any consequences resulting from the usage of this app.

### Credits

- [JioSaavn API](https://github.com/sumitkolhe/jiosaavn-api): Provides access to the Saavn music catalog.
- [Flutter](https://flutter.dev/): Framework for building cross-platform mobile applications.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Feel free to contribute, report issues, or suggest features to enhance the app!
