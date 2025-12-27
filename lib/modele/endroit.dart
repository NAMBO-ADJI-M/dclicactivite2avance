import 'package:dclicactivite2avance/modele/location.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Endroit {
  Endroit({
    required this.nom,
    required this.image,
    required this.location,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String nom;
  final String image;
  final EndroitLocation location;
}
