import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spoplusplusfy/Classes/artist_works_manager.dart';
import 'package:spoplusplusfy/Classes/song.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'album.dart';
import 'playlist.dart';

/// A singleton class that helps in managing the SQLite database.
class DatabaseHelper {
  /// Private constructor for singleton implementation.
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  /// Factory constructor that returns the same instance of [DatabaseHelper].
  factory DatabaseHelper() => _instance;

  /// SQLite database instance.
  static Database? _database;

  DatabaseHelper._internal();

  /// Getter for the database instance.
  /// If the database is already initialized, it returns the existing instance,
  /// otherwise, it initializes the database and returns the new instance.
  static Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  /// Checks if the database already exists, if not, it copies the database from assets.
  static Future<Database?> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'spo++fy_database.db');

    // Check if the database exists
    // If it doesn't exist, copy it from the assets
    ByteData data = await rootBundle.load('assets/database/spo++fy_database.db');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes);

    return openDatabase(path, version: 1);
  }

  /// Retrieves all the songs for a given [playlist].
  ///
  /// Queries the database for songs that belong to the playlist's album.
  /// Returns a list of [Song] objects.
  ///
  /// [playlist]: The playlist for which songs are to be fetched.
  Future<List<Song>> getSongsForPlaylist(Playlist playlist) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'songs',
      where: 'album_id=?',
      whereArgs: [playlist.getId()],
    );

    List<int> songIds = maps.map((e) => e['song_id'] as int).toList();
    final List<Map<String, dynamic>> songs = await db.query(
      'songs',
      where: 'song_id IN (${songIds.join(',')})',
    );

    return List.generate(songs.length, (i) {
      return Song(
        id: songs[i]['song_id'] ?? 000,
        duration: songs[i]['duration'] ?? 000,
        name: songs[i]['name'] ?? 'no_name',
        isMutable: false,
        volume: 100,
      );
    });
  }

  /// Retrieves a random playlist from the database.
  ///
  /// Queries the database for all playlists and selects one at random.
  /// Returns a [Playlist] object.
  /// Throws an exception if no playlists are available.
  Future<Playlist> getRandomPlaylist() async {
    return ArtistWorksManager.getRandomPlaylist();
  }
}
