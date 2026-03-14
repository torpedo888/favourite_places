import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPaths;
import 'package:sqflite/sqflite.dart' as sql;

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }

  Future<sql.Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute( //itt a create azert van hogy ha nincs meg a tabla akkor letrehozza, ha mar megvan akkor nem csinal semmit
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, loc_lat REAL, loc_lng REAL, address TEXT)',
        );
      },
    );
  }

  Future<void> loadPlaces() async {
    final db = await _getDatabase();

    final dataList = await db.query('user_places');
    final places = dataList.map((item) {
      return Place(
        id: item['id'] as String,
        title: item['title'] as String,
        image: File(item['image'] as String),
        location: PlaceLocation(
          latitude: item['loc_lat'] as double,
          longitude: item['loc_lng'] as double,
          address: item['address'] as String,
        ),
      );
    }).toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async{
    final appDir = await sysPaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    
    // Ensure the directory exists
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    // Read bytes from source and write to destination
    // This is more reliable than copy() when dealing with temp files
    final imageBytes = await image.readAsBytes();
    final savedImagePath = '${appDir.path}/$fileName';
    final savedImage = File(savedImagePath);
    await savedImage.writeAsBytes(imageBytes);

    final newPlace = Place(
      title: title,
      image: savedImage,
      location: location,
    );
    
    final db = await _getDatabase();
    await db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': savedImage.path,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  () => PlacesNotifier(),
);
