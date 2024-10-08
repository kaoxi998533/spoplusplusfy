import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spoplusplusfy/Classes/artist.dart';
import 'package:spoplusplusfy/Classes/artist_works_manager.dart';
import 'package:spoplusplusfy/Classes/playlist.dart';
import '../Classes/album.dart';
import '../Classes/song.dart';

/// A page that displays the details of a playlist and its songs.
class PlaylistPage extends StatefulWidget {
  final Playlist playlist; // The playlist to be displayed
  final List<Song> songs; // The list of songs in the playlist

  const PlaylistPage({super.key, required this.playlist, required this.songs});

  @override
  State<StatefulWidget> createState() => PlaylistPageState();
}

/// The state class for the PlaylistPage, managing its state and UI.
class PlaylistPageState extends State<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: _appBar(),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          _playlistInfo(),
          const SizedBox(
            height: 50,
          ),
          _songsList(),
          const SizedBox(
            height: 50,
          ),
          _recommendationList(),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  /// Builds the AppBar for the PlaylistPage.
  AppBar _appBar() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return AppBar(
      backgroundColor: primaryColor,
      leadingWidth: 80,
      toolbarHeight: 70,
      leading: GestureDetector(
        onTap: () {},
        child: FittedBox(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
              child: SvgPicture.asset(
                'assets/icons/heart_gold.svg',
                colorFilter: ColorFilter.mode(secondaryColor, BlendMode.srcIn),
              ),
            )),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: FittedBox(
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                  child: SvgPicture.asset(
                    'assets/icons/download_gold.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ))),
        ),
        GestureDetector(
          onTap: () {},
          child: FittedBox(
              alignment: Alignment.center,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                  child: SvgPicture.asset(
                    'assets/icons/dot_gold.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ))),
        ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  /// Builds the information section for the playlist, including the cover image and details.
  Row _playlistInfo() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(
          width: 25,
        ),
        Container(
          width: width / 3,
          height: width / 3,
          decoration: BoxDecoration(
              border: Border.all(
                color: secondaryColor,
                width: 3,
              ),
              color: secondaryColor,
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(widget.playlist.getCoverPath()),
                fit: BoxFit.cover,
              )),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: width / 2,
          height: width / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    widget.playlist.getName(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  ArtistWorksManager.getArtistsOfAlbumAsString(
                      widget.playlist as Album),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.songs.length} songs',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 17,
                    child: VerticalDivider(
                      color: secondaryColor,
                      thickness: 2,
                    ),
                  ),
                  Text(
                    '${widget.songs.map((song) => song.getDuration()).reduce((a, b) => a + b) ~/ 60} min',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          width: 25,
        ),
      ],
    );
  }

  /// Builds the list of songs in the playlist.
  ListView _songsList() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return ListView.separated(
        shrinkWrap: true,
        primary: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 25, right: 25),
        itemBuilder: (context, index) => Container(
          height: height / 13,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: secondaryColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 5,
              ),
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.w200,
                  fontSize: 30,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width / 2,
                    child: Text(
                      widget.songs[index].getName(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width / 3,
                    child: Text(
                      ArtistWorksManager.getArtistsOfSongAsString(
                          widget.songs[index]),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: width / 10,
                child: Text(
                  _formatTime(widget.songs[index].getDuration()),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 5,
          width: 5,
        ),
        itemCount: widget.songs.length);
  }

  /// Builds the recommendation list for albums by the primary artist of the current playlist.
  Visibility _recommendationList() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    Artist priArtist =
    ArtistWorksManager.getArtistsOfAlbum(widget.playlist as Album)[0];
    List<Album> rec = ArtistWorksManager.getAlbumsOfArtist(priArtist);
    return Visibility(
      visible: rec.isNotEmpty,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: SizedBox(
                  width: 350,
                  child: Text(
                    'More by ${priArtist.getName()}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: width * 3 / 7,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(
                width: 25,
              ),
              padding: const EdgeInsets.only(left: 25, right: 25),
              itemCount: rec.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: width / 3,
                      height: width / 3,
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          border: Border.all(
                            color: secondaryColor,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(rec[index].getCoverPath()),
                          )),
                    ),
                    Container(
                      width: 140,
                      alignment: Alignment.center,
                      child: Text(
                        rec[index].getName(),
                        style: TextStyle(
                          color: secondaryColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats the duration of a song into a string.
String _formatTime(int duration) {
  int h = duration ~/ 3600;
  int m = (duration - h * 3600) ~/ 60;
  String s = (duration - h * 3600 - m * 60).toString().padLeft(2, '0');
  return h != 0 ? '$h:$m:0$s' : '$m:$s';
}
