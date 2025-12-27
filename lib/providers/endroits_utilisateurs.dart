import 'dart:io';

import 'package:dclicactivite2avance/modele/endroit.dart';
import 'package:dclicactivite2avance/modele/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, nom TEXT, image TEXT, lat REAL, lng REAL)',
      );
    },
    version: 1,
  );
  return db;
}

class EndroitsUtilisateurs extends StateNotifier<List<Endroit>> {
  EndroitsUtilisateurs() : super(const []);

  Future<void> loadEndroits() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final endroits = data
        .map(
          (row) => Endroit(
            id: row['id'] as String,
            nom: row['nom'] as String,
            image: row['image'] as String,
            location: EndroitLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
            ),
          ),
        )
        .toList();

    state = endroits;
  }

  Future<void> ajoutendroit(String nom, File image, EndroitLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final nouveauEndroit = Endroit(
      nom: nom,
      image: copiedImage.path,
      location: location,
    );

    final db = await _getDatabase();
    db.insert(
      'user_places',
      {
        'id': nouveauEndroit.id,
        'nom': nouveauEndroit.nom,
        'image': nouveauEndroit.image,
        'lat': nouveauEndroit.location.latitude,
        'lng': nouveauEndroit.location.longitude,
      },
    );

    state = [nouveauEndroit, ...state];
  }

  Future<void> modifierEndroit(String id, String nom, File image, EndroitLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final endroitModifie = Endroit(
      id: id,
      nom: nom,
      image: copiedImage.path,
      location: location,
    );

    final db = await _getDatabase();
    await db.update(
      'user_places',
      {
        'nom': endroitModifie.nom,
        'image': endroitModifie.image,
        'lat': endroitModifie.location.latitude,
        'lng': endroitModifie.location.longitude,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    state = [ for (final e in state) e.id == id ? endroitModifie : e ];
  }

  Future<void> supprimerEndroit(Endroit endroit) async {
    final db = await _getDatabase();
    await db.delete(
      'user_places',
      where: 'id = ?',
      whereArgs: [endroit.id],
    );

    // Supprimer le fichier image pour libérer de l'espace
    final imageFile = File(endroit.image);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }

    state = state.where((e) => e.id != endroit.id).toList();
  }
}

final endroitsProvider =
    StateNotifierProvider<EndroitsUtilisateurs, List<Endroit>>(
  (ref) => EndroitsUtilisateurs(),
);
