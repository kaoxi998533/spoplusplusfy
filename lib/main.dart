import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spoplusplusfy/Classes/artist.dart';
import 'package:spoplusplusfy/Classes/person.dart';
import 'package:spoplusplusfy/Pages/main_page.dart';
import 'package:spoplusplusfy/Pages/search_page.dart';

import 'Classes/album.dart';
import 'Classes/song.dart';
import 'Utilities/search_engine.dart';

void main() {
  runApp(MainPage());
  Set<Artist> artset = { 
    Artist(name: 'Prince', id: 1, gender: Gender.Male, portrait: const Image(image: AssetImage('assets/images/prince.jpg')), age: 57),
  };
  Set<Album> albset = {
    Album(name: 'Sign O\' The Time', playlistCoverPath: 'assets/images/sign.webp', id: 1, timelength: 1, artist: artset.first),
    Album(name: 'Purple Rain',  playlistCoverPath: 'assets/images/purple_rain.webp', id: 2, timelength: 1, artist: artset.first),
  };
  Set<Song> sonset = {
    Song(name: 'Purple Rain', id: 750, duration: 1000, volume: 100, artist: artset.first, playlist: albset.first, isMutable: false),
    Song(name: 'Raspberry Beret', id: 751, duration: 1000, volume: 100, artist: artset.first, playlist: albset.first, isMutable: false),
  };
  SearchEngine searchEngine = SearchEngine.init(artset, albset, {}, sonset, HashSet());

}

class Spoplusplusfy extends StatelessWidget {
  const Spoplusplusfy({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Colors.black, secondary: Color(0xffFFE8A3)),
        fontFamily: 'NotoSans',
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xffFFE8A3),
        )
      ),
      home: const SearchPage(),
    );
  }
}
