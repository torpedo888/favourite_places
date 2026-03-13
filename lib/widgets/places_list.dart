import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/screens/place_detail.dart';
import 'package:flutter/material.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({
    super.key,
    required this.places,
  });

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if(places.isEmpty) {
      return const Center(
        child: Text('No places added yet.'),
      );
    }

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) => ListTile(
        key: ValueKey(places[index].id),
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: FileImage(places[index].image),
        ),
        title: Text(places[index].title, 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),),
        subtitle: Text(places[index].location.address, 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PlaceDetailScreen(place: places[index]),
            ),
          );
        },
      ),
    );
  }
}