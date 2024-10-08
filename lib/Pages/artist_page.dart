import 'package:flutter/material.dart';
import 'package:spoplusplusfy/Classes/artist.dart';
import 'package:spoplusplusfy/Classes/artist_works_manager.dart';
import 'package:spoplusplusfy/Pages/playlist_page.dart';
import 'package:spoplusplusfy/Pages/pro_mode_player_page.dart';

import '../Classes/album.dart';
import '../Classes/playlist.dart';
import '../Classes/playlist_song_manager.dart';

/// A widget that displays an artist's page, including their information, works, and posts.
class ArtistPage extends StatefulWidget {
  /// The artist whose information is being displayed.
  final Artist artist;

  /// Creates an [ArtistPage] widget.
  ///
  /// The [artist] parameter is required and represents the artist to be displayed.
  const ArtistPage({super.key, required this.artist});

  @override
  State<StatefulWidget> createState() => ArtistPageState();
}

/// The state for the [ArtistPage] widget.
class ArtistPageState extends State<ArtistPage> {
  /// Index of the currently selected tab.
  int _selectedIdx = 0;

  /// Controller for the page view.
  final PageController _controller = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: _infoBar(),
      backgroundColor: primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavigationBar(),
          _pageView(),
        ],
      ),
    );
  }

  /// Builds the navigation bar for switching between Works and Posts.
  NavigationBar _buildNavigationBar() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return NavigationBar(
      backgroundColor: primaryColor,
      height: height / 40,
      selectedIndex: _selectedIdx,
      destinations: [
        NavigationDestination(
            selectedIcon: SizedBox(
              height: height / 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: secondaryColor,
                ),
                onPressed: () {
                  _selectedIdx = 0;
                  _controller.animateToPage(_selectedIdx,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.bounceInOut);
                  setState(() {});
                },
                child: Text(
                  'Works',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: primaryColor),
                ),
              ),
            ),
            icon: SizedBox(
              height: height / 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 2.0, color: secondaryColor),
                ),
                onPressed: () {
                  _selectedIdx = 0;
                  _controller.animateToPage(_selectedIdx,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.bounceInOut);
                  setState(() {});
                },
                child: Text(
                  'Works',
                  style: TextStyle(
                      color: secondaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            label: ''),
        NavigationDestination(
            selectedIcon: SizedBox(
              height: height / 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: secondaryColor,
                ),
                onPressed: () {
                  _selectedIdx = 1;
                  _controller.animateToPage(_selectedIdx,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.bounceInOut);
                  setState(() {});
                },
                child: Text(
                  'Posts',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: primaryColor),
                ),
              ),
            ),
            icon: SizedBox(
              height: height / 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 2.0, color: secondaryColor),
                ),
                onPressed: () {
                  _selectedIdx = 1;
                  _controller.animateToPage(_selectedIdx,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.bounceInOut);
                  setState(() {});
                },
                child: Text('Posts',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    )),
              ),
            ),
            label: '')
      ],
    );
  }

  /// Creates the page view for Works and Posts.
  Container _pageView() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Container(
      color: primaryColor,
      height: MediaQuery.of(context).size.height * 2 / 3,
      child: PageView(
        controller: _controller,
        onPageChanged: (index) => {
          _selectedIdx = index,
          setState(() {}),
        },
        children: [_workPage(), _postPage()],
      ),
    );
  }

  /// Builds the Works page, including recommended showcases and album grid.
  ListView _workPage() {
    return ListView(
      children: [
        _recommendShowcase(),
        _buildGridAlbums(ArtistWorksManager.getAlbumsOfArtist(widget.artist)),
      ],
    );
  }

  /// Builds the Posts page (currently a placeholder).
  ListView _postPage() {
    return ListView(
      children: [
        Container(
          color: Colors.blue,
          height: 500,
        ),
        Container(
          color: Colors.green,
          height: 250,
        ),
      ],
    );
  }

  /// Creates the app bar with artist information.
  AppBar _infoBar() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AppBar(
      toolbarHeight: height / 4,
      backgroundColor: primaryColor,
      leading: Row(
        children: [
          const SizedBox(
            width: 25,
          ),
          Container(
            height: width / 3,
            width: width / 3,
            alignment: Alignment.center,
            child: Container(
              width: width / 3,
              height: width / 3,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: secondaryColor, width: 3),
                borderRadius: BorderRadius.circular(width / 3),
              ),
              child: ClipOval(
                child: widget.artist.getPortrait(),
              ),
            ),
          ),
          const SizedBox(
            width: 25,
          ),
        ],
      ),
      leadingWidth: width / 2,
      actions: [
        SizedBox(
          width: width / 2,
          height: width / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.artist.getName(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.all(secondaryColor),
                      ),
                      onPressed: () => {},
                      child: Text('Follow', style: TextStyle(color: primaryColor),)),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Flexible(
                child: Text(
                  'Some random introduction to the singer/band',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 25,
        ),
      ],
    );
  }

  /// Builds the recommended showcase section.
  Visibility _recommendShowcase() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    List<Album> albums = ArtistWorksManager.getAlbumsOfArtist(widget.artist);
    return Visibility(
      visible: albums.isNotEmpty,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Recommended to you',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width / 2.5,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(
                width: 25,
              ),
              padding: const EdgeInsets.only(left: 25, right: 25),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlaylistPage(
                                playlist: albums[index],
                                songs: PlaylistSongManager.getSongsForPlaylist(
                                    albums[index]))))
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: secondaryColor,
                              width: 3,
                            ),
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(albums[index].getCoverPath()),
                              fit: BoxFit.cover,
                            )),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          albums[index].getName(),
                          style: TextStyle(
                            color: secondaryColor,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Creates a grid view of albums.
  ///
  /// [playlists] is the list of playlists (albums) to display.
  Column _buildGridAlbums(List<Playlist> playlists) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                'Albums',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProModePlayerPage(playlist: playlists[index]),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: secondaryColor,
                          width: 3,
                        ),
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: NetworkImage(playlists[index].getCoverPath(),
                              scale: 0.1),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  alignment: Alignment.center,
                  child: Text(
                    playlists[index].getName(),
                    style: TextStyle(
                      color: secondaryColor,
                      fontFamily: 'Noto-Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          itemCount: playlists.length,
        ),
      ],
    );
  }
}