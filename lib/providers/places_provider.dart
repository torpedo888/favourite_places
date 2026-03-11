import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }

  void addPlace(String title, File image) {
    final newPlace = Place(title: title, image: image);
    state = [newPlace, ...state];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  () => PlacesNotifier(),
);
