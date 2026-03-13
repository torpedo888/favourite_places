import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          // Full-size image
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Bottom overlay with circular map and address
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular map
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => MapScreen(
                            location: place.location,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 3,
                          color: Colors.white,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: IgnorePointer(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                place.location.latitude,
                                place.location.longitude,
                              ),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.example.favourite_places',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      place.location.latitude,
                                      place.location.longitude,
                                    ),
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Address text
                  Text(
                    place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
