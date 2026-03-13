import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }

  void addPlace(String title, File image, PlaceLocation location) {
    final newPlace = Place(
      title: title,
      image: image,
      location: location,
    );
    state = [newPlace, ...state];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  () => PlacesNotifier(),
);
