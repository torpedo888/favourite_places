import 'package:favourite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {

  const MapScreen({
    super.key,
    required this.location,
  });
  
  final PlaceLocation location;
  
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Could re-center the map if needed
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          initialZoom: 16,
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
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  } 
}