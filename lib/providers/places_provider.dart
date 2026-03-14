import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
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
    try {
      final db = await _getDatabase();

      final dataList = await db.query('user_places');
      print('Loading places from database: ${dataList.length} items found');
      
      final places = <Place>[];
      
      for (var item in dataList) {
        final imagePath = item['image'] as String;
        final imageFile = File(imagePath);
        
        print('Loading place: ${item['title']} with image: $imagePath');
        
        // Check if image file still exists
        if (await imageFile.exists()) {
          places.add(Place(
            id: item['id'] as String,
            title: item['title'] as String,
            image: imageFile,
            location: PlaceLocation(
              latitude: item['loc_lat'] as double,
              longitude: item['loc_lng'] as double,
              address: item['address'] as String,
            ),
          ));
          print('Place loaded successfully');
        } else {
          print('Image file not found, skipping place: ${item['title']}');
          // Optionally, delete the database entry
          await db.delete('user_places', where: 'id = ?', whereArgs: [item['id']]);
        }
      }

      state = places;
      print('Places loaded successfully: ${places.length} items');
    } catch (e) {
      print('Error loading places: $e');
      state = [];
    }
  }

  Future<void> addPlace(String title, File image, PlaceLocation location) async{
    // Image is already saved by image_input widget
    // Just use it directly
    
    print('Adding place: $title');
    print('Image path: ${image.path}');
    print('Image exists: ${await image.exists()}');
    
    final newPlace = Place(
      title: title,
      image: image,
      location: location,
    );
    
    final db = await _getDatabase();
    print('Database path: ${await sql.getDatabasesPath()}');
    
    await db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': image.path,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    
    print('Place saved to database successfully');

    state = [newPlace, ...state];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  () => PlacesNotifier(),
);
