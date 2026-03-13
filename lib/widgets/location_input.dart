import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(double latitude, double longitude, String address) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationData? _pickedLocation;
  var _isGettingLocation = false;

  String _getLocationAddress(double lat, double lng) {
    return '$lat, $lng';
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
    );
    
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FavouritePlacesApp/1.0'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;
        if (address != null) {
          return address;
        }
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    
    return _getLocationAddress(lat, lng);
  }

  void _getCurrentLocation() async {  
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    
    print('Location obtained: ${locationData.latitude}, ${locationData.longitude}');
    
    final address = await _getAddressFromCoordinates(
      locationData.latitude!,
      locationData.longitude!,
    );
    
    setState(() {
      _isGettingLocation = false;
      _pickedLocation = locationData;
    });

    widget.onSelectLocation(
      locationData.latitude!,
      locationData.longitude!,
      address,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location Chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_pickedLocation != null) {
      print('Rendering map with location: ${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}');
      previewContent = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              _pickedLocation!.latitude!,
              _pickedLocation!.longitude!,
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
                    _pickedLocation!.latitude!,
                    _pickedLocation!.longitude!,
                  ),
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if(_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: _pickedLocation == null ? Alignment.center : null,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on), 
              label: const Text('Get Current Location'), 
              onPressed: _getCurrentLocation),
            TextButton.icon(
              icon: const Icon(Icons.map), 
              label: const Text('Select on Map'), 
              onPressed: () {}),
          ],
        )
      ],
    );
  }
}
