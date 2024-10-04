# spoplusplusfy

Spoplusplusfy - An Orbital Project

Spoplusplusfy is a music streaming application built using Flutter. It features a rich UI for managing playlists, songs, and artists, and provides a seamless music listening experience with advanced audio controls. The app leverages SQLite for local database management and Just Audio for audio playback.

## Table of Contents

- [Introduction](#introduction)
- [Level of Achievement](#level-of-achievement)
- [Project Scope](#project-scope)
- [User Stories](#user-stories)
- [Motivation](#motivation)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Code Documentation](#code-documentation)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project is a multi-modal music player

Here is the UI design:

<img width="864" alt="UI" src="https://github.com/dingf3ng/spoplusplusfy/assets/103719642/50b42d64-a76a-4b27-bdc8-f7da158805cc">

## Level of Achievement

Apollo

## Project Scope

- One-sentence: A multi-modal music player for both curated and average music enjoyers.

- Niubi: good

- Longer version: We will develop a music player with support for streaming music such that the user can listen to their favorite music everywhere with their phones. Additionally, we have social modes and pro modes to allow users to edit their music for their own practice, as well as discuss their favorite music with people alike around the globe with our platform.

## User Stories

- A user seeking a refreshing and straightforward music player interface that prioritizes uninterrupted listening without the clutter of unnecessary features. The user can use Pure Mode.
- A music aficionado looking for new tunes, eager to leverage a sophisticated, tailored recommendation system for discovering their next favorite song.
- A sociable music lover interested in connecting with others who share their musical tastes, eager to exchange thoughts and experiences related to their favorite tracks.
- An aspiring musician aiming to enhance their skills, in need of advanced features that allow for the isolation and replacement of specific instrument tracks within a song with their own recordings.
## Motivation

Currently, mainstream music players on the market tend to fall into one of two categories: those with limited features and those with overly complex user interfaces. This leaves users with varied needs—ranging from uninterrupted listening experiences to social interactions with like-minded music enthusiasts and sharing music reviews—without a single, versatile platform. As a result, users find themselves toggling between multiple applications to fulfill their diverse requirements. We believe in the principle that "less is more" and anticipate a strong demand for a unified solution that eliminates the need for multiple software, catering to the diverse needs and preferences of all users.

## Features

- Browse and play songs from curated playlists.
- Swipe to change tracks.
- Play, pause, fast-forward, and rewind tracks.
- Search for songs and playlists.
- Manage playlists and add or remove songs.
- View artist information and songs.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/spoplusplusfy.git
   cd spoplusplusfy
   
2. **Install dependencies:**
   ```bash
   flutter pub get

3. **Install songs**
   unzip folder **songs.zip** in https://drive.google.com/file/d/1cjJYS_tzfEeLd83guGTlnFSXsJ0c0Mcy/view?usp=sharing. Copy the songs folder into the assets folder in the project directory.

3. **Run the app:**
   ```bash
   flutter run

## Usage
Main Page: Displays a list of random playlists. Tap on a playlist to navigate to the player page.
Player Page: Shows the currently playing song and artist. Use swipe gestures to switch tracks and control buttons to play/pause the music.
Search Page: Allows searching for songs and playlists. Provides quick access to settings and user profile.

## Classes
- Artist: Represents an artist and their associated songs and albums.
- DatabaseHelper: Manages the SQLite database for storing playlists and songs.
- FollowerManager: Manages the followers and following relationships between Person objects.
- Person: Represents a person with attributes like name, gender, age, and portrait.
- Playlist: Represents a music playlist with methods to manage it.
- PlaylistIterator: Manages the playback of songs in a playlist using Just Audio.
- PlaylistSongManager: Manages the relationship between playlists and songs.
- Song: Represents a song with attributes like name, artist, and playlist.
- Voice: Represents a generic audio entity with an audio source.
 
## Pages
- MainPage: The main landing page of the app that displays playlists.
- PlayerPage: The player interface for playing songs and controlling playback.
- SearchPage: The search interface for finding songs and playlists.

## Code Documentation
Each class and method is documented using DartDoc comments. Below are some examples:

- MainPage
```dart
  /// A stateless widget representing the main page of the application.
  class MainPage extends StatelessWidget {
  /// Fetches a list of random playlists from the database.
  ///
  /// Returns a [Future] that completes with a list of [Playlist] objects.
  Future<List<Playlist>> _getPlaylists() async {
  // Implementation...
  }

  @override
  Widget build(BuildContext context) {
  // Implementation...
  }
  }
```

```dart
/// A stateful widget representing the player page.
class PlayerPage extends StatefulWidget {
  /// The playlist to be played.
  final Playlist playlist;

  PlayerPage({required this.playlist});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

/// The state for the [PlayerPage] widget.
class _PlayerPageState extends State<PlayerPage> {
  // Implementation...
}
```

## Contributing
We do not accept contributions at this time.

## License
This project is licensed under the MIT License. See the LICENSE file for more information.

