import 'package:spoplusplusfy/Classes/artist_works_manager.dart';
import 'package:spoplusplusfy/Classes/person.dart';

class Artist extends Person {

  Artist({
    required super.name,
    required super.id,
    required super.gender,
    required super.portrait
  });

  // @override
  // void delete() {
  //   super.delete();
  //   ArtistWorksManager.deleteArtist(this);
  // }

}