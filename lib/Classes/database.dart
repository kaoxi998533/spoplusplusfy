import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:spoplusplusfy/Classes/artist_works_manager.dart';
import 'package:spoplusplusfy/Classes/playlist_song_manager.dart';
import 'package:spoplusplusfy/Classes/song.dart';
import 'package:spoplusplusfy/Utilities/search_engine.dart';
import 'package:http/http.dart' as http;

import '../Utilities/api_service.dart';
import 'album.dart';
import 'artist.dart';
import 'playlist.dart';

/// A singleton class that helps in managing the SQLite database.
class DatabaseHelper {
  /// Private constructor for singleton implementation.
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  /// Factory constructor that returns the same instance of [DatabaseHelper].
  factory DatabaseHelper() => _instance;

  /// Private constructor for internal use.
  DatabaseHelper._internal();

  /// Initializes the frontend data by loading from the database.
  static Future<void> initializeFrontendData() async {
    await _loadFromDatabase();
  }

  /// Loads data from the database and initializes the application's data structures.
  ///
  /// This method retrieves albums, songs, and artists from the database,
  /// creates necessary mappings, and initializes the data managers.
  static Future<void> _loadFromDatabase() async {
    // Fetch albums from the database
    final jsonAlbums = await http.get(Uri.http('$fhlIP', '/api/db/load_from_database/albums'));
    final List<dynamic> albumMaps = await jsonDecode(jsonAlbums.body);
    final List<Album> albums = albumMaps.map((map) => Album.fromMap(map)).toList();

    // Fetch songs from the database
    final jsonSongs = await http.get(Uri.http(fhlIP, '/api/db/load_from_database/songs'));
    final List<dynamic> songMaps = await jsonDecode(jsonSongs.body);
    final List<Song> songs = songMaps.map((map) => Song.fromMap(map)).toList();

    // Fetch artists from the database
    final jsonArtists = await http.get(Uri.http(fhlIP, '/api/db/load_from_database/artists'));
    final List<dynamic> artistMap = await jsonDecode(jsonArtists.body);
    final List<Artist> artists = artistMap.map((map) => Artist.fromMap(map)).toList();

    // Create mappings
    HashMap<int, Album> id2Album = HashMap();
    HashMap<int, Song> id2Song = HashMap();
    HashMap<String, Artist> name2Artist = HashMap();
    HashMap<int, String> songId2ArtistName = HashMap();

    for (Album album in albums) {
      id2Album.putIfAbsent(album.getId(), () => album);
    }
    for (Song song in songs) {
      id2Song.putIfAbsent(song.getId(), () => song);
    }
    for (Artist artist in artists) {
      name2Artist.putIfAbsent(artist.getName(), () => artist);
    }

    final Map<Song, Album> songs2Albums = HashMap();
    for (var map in songMaps) {
      final int song_id = map['song_id'];
      final int album_id = map['album_id'];
      songs2Albums.putIfAbsent(id2Song[song_id]!, () => id2Album[album_id]!);
      songId2ArtistName.putIfAbsent(map['song_id'], () => map['artist_name'] ?? 'unknown');
    }

    // Initialize data managers
    await _initManagers(albums, songs, artists, id2Album, id2Song, name2Artist,
        songMaps, songs2Albums, songId2ArtistName);
  }

  /// Initializes the data managers with the loaded data.
  ///
  /// This method initializes ArtistWorksManager, PlaylistSongManager, and SearchEngine
  /// with the data loaded from the database.
  static Future<void> _initManagers(
      List<Album> albums,
      List<Song> songs,
      List<Artist> artists,
      HashMap<int, Album> id2Album,
      HashMap<int, Song> id2Song,
      HashMap<String, Artist> name2Artist,
      List<dynamic>? relationships,
      Map<Song, Album> songs2Albums,
      Map<int, String> songId2ArtistName,
      ) async {
    // Initialize ArtistWorksManager
    await ArtistWorksManager.init(
        albums, songs, artists, id2Album, id2Song, name2Artist, relationships,
        songId2ArtistName, songs2Albums);

    // Initialize PlaylistSongManager
    await PlaylistSongManager.init(
        albums, songs, id2Album, id2Song, songs2Albums);

    // Initialize SearchEngine
    SearchEngine.init(
        artists.toSet(), albums.toSet(), {}, songs.toSet(), HashSet());
  }

  /// Retrieves a random playlist from the database.
  ///
  /// Queries the database for all playlists and selects one at random.
  /// Returns a [Playlist] object.
  /// Throws an exception if no playlists are available.
  @Deprecated('try to use "ArtistWorkManager::getRandomPlaylist" instead')
  Future<Playlist> getRandomPlaylist() async {
    return ArtistWorksManager.getRandomPlaylist();
  }
}