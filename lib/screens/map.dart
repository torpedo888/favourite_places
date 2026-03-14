import 'package:favourite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {

  const MapScreen({
    super.key,
    required this.location,
    this.isSelecting = false,
  });
  
  final PlaceLocation location;
  final bool isSelecting;
  
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      currentZoom + 1,
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      currentZoom - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Tap to Pick Location' : 'Map'),
        actions: [
          if (widget.isSelecting && _pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Confirm Location',
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          initialZoom: 16,
          minZoom: 3,
          maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | 
                   InteractiveFlag.drag | 
                   InteractiveFlag.doubleTapZoom |
                   InteractiveFlag.flingAnimation,
          ),
          onTap: widget.isSelecting
              ? (tapPosition, point) {
                  print('Map tapped at: ${point.latitude}, ${point.longitude}');
                  setState(() {
                    _pickedLocation = point;
                  });
                  print('Marker set to: $_pickedLocation');
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.example.favourite_places',
          ),
          MarkerLayer(
            markers: [
              if (widget.isSelecting && _pickedLocation != null)
                Marker(
                  point: _pickedLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 50,
                  ),
                ),
              if (!widget.isSelecting)
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
          // Instruction hint for selection mode
          if (widget.isSelecting && _pickedLocation == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the map to place a marker',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}