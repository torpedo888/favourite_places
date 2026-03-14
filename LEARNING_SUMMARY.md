# Favourite Places Project - Learning Summary

## What I Learned

This document summarizes all the concepts, technologies, and best practices learned while building the Favourite Places Flutter application.

---

## **State Management**

### **Riverpod**
State management library for Flutter that provides dependency injection and reactive state updates.

```dart
class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  () => PlacesNotifier(),
);
```

### **NotifierProvider**
Riverpod provider that exposes a Notifier for managing mutable state.

### **Notifier**
Class that holds and manages state, provides methods to update it.

### **ConsumerWidget**
Widget that can read Riverpod providers and rebuilds when they change.

### **ConsumerStatefulWidget**
Stateful version of ConsumerWidget with lifecycle methods.

```dart
class PlacesListScreen extends ConsumerStatefulWidget {
  const PlacesListScreen({super.key});

  @override
  ConsumerState<PlacesListScreen> createState() => _PlacesListScreenState();
}
```

### **ref.read() vs ref.watch()**
- **ref.read()** - Reads provider value once without subscribing to changes (for one-time actions)
- **ref.watch()** - Subscribes to provider and rebuilds widget when state changes

```dart
// read - for one-time actions (doesn't rebuild)
_placesFuture = ref.read(placesProvider.notifier).loadPlaces();

// watch - subscribes to changes (rebuilds on change)
final places = ref.watch(placesProvider);
```

### **state**
Property in Notifier to get/set the current state value.

```dart
state = [newPlace, ...state];  // Update state in Riverpod
```

---

## **Async Programming**

### **Future**
Represents a value that will be available at some point in the future.

### **Future<void>**
Future that returns no value when complete.

```dart
Future<void> loadPlaces() async {
  final db = await _getDatabase();
  // ...
}
```

### **async**
Keyword to mark a function as asynchronous.

### **await**
Pauses execution until a Future completes and returns its value.

```dart
void _selectOnMap() async {
  final pickedLocation = await Navigator.of(context).push<LatLng>(
    MaterialPageRoute(builder: (ctx) => MapScreen(...)),
  );
}
```

### **late**
Declares a non-nullable variable that will be initialized later (before first use).

```dart
late Future<void> _placesFuture;  // Will be initialized later

@override
void initState() {
  super.initState();
  _placesFuture = ref.read(placesProvider.notifier).loadPlaces();
}
```

**Why use late?** It gives you non-nullable type safety without requiring immediate initialization. Without it, you'd need to make the variable nullable (`Future<void>?`) which requires null checks, or initialize with a dummy value.

### **FutureBuilder**
Widget that builds itself based on Future's state (waiting, done, error).

```dart
FutureBuilder(
  future: _placesFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    return PlacesList(places: places);
  },
)
```

### **Future.microtask()**
Schedules a callback to run after the current synchronous code.

---

## **Database (SQLite)**

### **sqflite**
Flutter plugin for SQLite database operations.

### **CREATE TABLE**
SQL command to create a new database table.

```dart
onCreate: (db, version) {
  return db.execute(
    'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, loc_lat REAL, loc_lng REAL, address TEXT)',
  );
}
```

### **INSERT**
SQL operation to add new rows to a table.

```dart
await db.insert('user_places', {
  'id': newPlace.id,
  'title': newPlace.title,
  'image': savedImage.path,
  'loc_lat': newPlace.location.latitude,
  'loc_lng': newPlace.location.longitude,
  'address': newPlace.location.address,
});
```

### **QUERY**
SQL operation to retrieve data from a table.

```dart
final dataList = await db.query('user_places');
```

### **onCreate**
Callback that runs once when database is first created.

### **getDatabasesPath()**
Returns the default database directory path.

### **openDatabase()**
Opens/creates a database file.

```dart
final dbPath = await sql.getDatabasesPath();
return sql.openDatabase(
  path.join(dbPath, 'places.db'),
  version: 1,
  onCreate: (db, version) { ... },
);
```

---

## **Images**

### **image_picker**
Flutter plugin to pick images from camera or gallery.

```dart
final imagePicker = ImagePicker();
final pickedImage = await imagePicker.pickImage(
  source: ImageSource.camera, 
  maxWidth: 600
);
```

### **File**
Dart class representing a file on the filesystem.

```dart
File? _selectedImage;
_selectedImage = File(pickedImage.path);
```

### **readAsBytes()**
Reads entire file contents as bytes.

### **writeAsBytes()**
Writes bytes to a file.

```dart
final imageBytes = await image.readAsBytes();
final savedImage = File(savedImagePath);
await savedImage.writeAsBytes(imageBytes);
```

### **Image.file**
Widget that displays an image from a File.

### **BoxFit.cover**
Scales image to cover entire space while maintaining aspect ratio.

```dart
Image.file(
  place.image,
  fit: BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
)
```

### **path_provider**
Plugin to find commonly used locations on the filesystem.

### **getApplicationDocumentsDirectory**
Returns directory for app-specific persistent files.

```dart
final appDir = await sysPaths.getApplicationDocumentsDirectory();
final savedImagePath = '${appDir.path}/$fileName';
```

---

## **Location & GPS**

### **location package**
Plugin for accessing device location services.

### **PermissionStatus**
Enum representing location permission state (denied, granted, etc.).

```dart
bool serviceEnabled;
PermissionStatus permissionGranted;

serviceEnabled = await location.serviceEnabled();
if (!serviceEnabled) {
  serviceEnabled = await location.requestService();
}

permissionGranted = await location.hasPermission();
if (permissionGranted == PermissionStatus.denied) {
  permissionGranted = await location.requestPermission();
}
```

### **getLocation()**
Gets device's current GPS coordinates.

```dart
locationData = await location.getLocation();
```

### **Geocoding**
Converting addresses to coordinates.

### **Reverse geocoding**
Converting coordinates to human-readable addresses.

```dart
Future<String> _getAddressFromCoordinates(double lat, double lng) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
  );
  final response = await http.get(url, headers: {'User-Agent': '...'});
  final data = json.decode(response.body);
  return data['display_name'] as String?;
}
```

### **http package**
For making HTTP requests to APIs.

### **PlaceLocation**
Custom model class to store location data.

---

## **Maps**

### **flutter_map**
Open-source map widget for Flutter.

### **TileLayer**
Displays map tiles from a tile server (like OpenStreetMap).

```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(place.location.latitude, place.location.longitude),
    initialZoom: 16,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c', 'd'],
    ),
  ],
)
```

### **MarkerLayer**
Adds markers/pins to map locations.

```dart
MarkerLayer(
  markers: [
    Marker(
      point: LatLng(latitude, longitude),
      width: 80,
      height: 80,
      child: const Icon(Icons.location_on, color: Colors.red, size: 50),
    ),
  ],
)
```

### **MapController**
Controls map programmatically (zoom, pan, center).

```dart
final MapController _mapController = MapController();

void _zoomIn() {
  final currentZoom = _mapController.camera.zoom;
  _mapController.move(_mapController.camera.center, currentZoom + 1);
}
```

### **MapOptions**
Configuration for map behavior (zoom levels, center, interactions).

### **InteractiveFlag**
Flags to enable/disable map interactions (pinch, drag, tap).

```dart
interactionOptions: const InteractionOptions(
  flags: InteractiveFlag.pinchZoom | 
         InteractiveFlag.drag | 
         InteractiveFlag.doubleTapZoom,
)
```

### **LatLng**
Class representing latitude/longitude coordinates.

---

## **UI Widgets & Layouts**

### **Stack**
Widget that overlays children on top of each other.

### **Positioned**
Positions a child within a Stack at specific coordinates.

```dart
Stack(
  children: [
    Image.file(place.image, fit: BoxFit.cover, ...),
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(...),
    ),
  ],
)
```

### **GestureDetector**
Widget that detects gestures like taps, drags, swipes.

```dart
GestureDetector(
  onTap: () {
    Navigator.of(context).push(MaterialPageRoute(...));
  },
  child: Container(...),
)
```

### **IgnorePointer**
Makes child widget ignore all pointer events (touches).

```dart
child: IgnorePointer(
  child: FlutterMap(...),  // Map won't receive touch events
)
```

### **ClipOval**
Clips child widget into circular/oval shape.

```dart
ClipOval(
  child: FlutterMap(...),  // Makes the map circular
)
```

### **CircularProgressIndicator**
Spinning loading indicator.

### **TextButton.icon**
Button with both icon and text label.

### **Tooltip**
Shows hint text on long press.

---

## **Styling**

### **BoxDecoration**
Defines how a box should be painted (borders, shadows, gradients).

```dart
decoration: BoxDecoration(
  shape: BoxShape.circle,
  border: Border.all(width: 3, color: Colors.white),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 10,
      spreadRadius: 2,
    ),
  ],
)
```

### **LinearGradient**
Gradient that transitions linearly between colors.

```dart
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
)
```

### **BoxShadow**
Shadow effect for containers.

### **BoxShape.circle**
Makes a container circular.

### **withOpacity()**
Returns color with modified opacity value.

### **withValues(alpha:)**
Returns color with modified alpha channel value.

```dart
Colors.black.withOpacity(0.7)
Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
```

### **Theme.of(context)**
Accesses current app theme for consistent styling.

---

## **Navigation**

### **Navigator.push**
Navigates to a new screen (adds to navigation stack).

### **Navigator.pop**
Returns to previous screen (removes from stack).

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (ctx) => MapScreen(location: place.location),
  ),
);

Navigator.of(context).pop(_pickedLocation);  // Return data
```

### **MaterialPageRoute**
Defines a route with Material Design page transition.

### **Passing data to screens**
Send data via constructor when navigating.

### **Returning data from screens**
Use pop() with a value to return data.

```dart
final pickedLocation = await Navigator.of(context).push<LatLng>(
  MaterialPageRoute(builder: (ctx) => MapScreen(...)),
);
```

---

## **Dart Concepts**

### **Collection-if**
Conditionally include items in a list using `if` inside the list literal.

```dart
markers: [
  if (widget.isSelecting && _pickedLocation != null)
    Marker(point: _pickedLocation!, ...),
  if (!widget.isSelecting)
    Marker(point: LatLng(widget.location.latitude, ...), ...),
]
```

### **.map()**
Transforms each item in a collection to create a new collection.

```dart
final places = dataList.map((item) {
  return Place(
    id: item['id'] as String,
    title: item['title'] as String,
    image: File(item['image'] as String),
    location: PlaceLocation(...),
  );
}).toList();
```

### **Arrow functions**
Shorthand function syntax: `() => expression`.

```dart
onPressed: () => Navigator.of(context).push(...)
```

### **Optional parameters**
Function parameters that have default values and can be omitted.

### **Named parameters**
Parameters referenced by name when calling functions.

```dart
const MapScreen({
  super.key,
  required this.location,
  this.isSelecting = false,  // Optional with default value
})
```

### **? (nullable)**
Marks a type as nullable (can be null).

### **! (null assertion)**
Asserts a nullable value is non-null (throws if null).

### **?? (null coalescing)**
Returns right value if left is null.

```dart
File? _selectedImage;              // Nullable
widget.onPickImage(_selectedImage!);  // Null assertion
final address = data['display_name'] as String?;  // Nullable cast
```

---

## **File System**

### **path package**
Utilities for manipulating file paths.

### **basename()**
Extracts filename from a full path.

### **join()**
Combines path segments into a single path.

```dart
final fileName = path.basename(image.path);
path.join(dbPath, 'places.db')
```

### **Directory.create()**
Creates a directory.

### **recursive: true**
Creates parent directories if they don't exist.

### **exists()**
Checks if file or directory exists.

```dart
if (!await appDir.exists()) {
  await appDir.create(recursive: true);
}
```

---

## **HTTP & Networking**

### **http package**
For making HTTP requests.

### **http.get()**
Sends HTTP GET request to a URL.

```dart
final response = await http.get(
  url,
  headers: {'User-Agent': 'FavouritePlacesApp/1.0'},
);
```

### **Headers**
Metadata sent with HTTP requests (like User-Agent).

### **json.decode()**
Parses JSON string into Dart Map/List.

```dart
final data = json.decode(response.body);
final address = data['display_name'] as String?;
```

### **Uri.parse()**
Converts string URL into Uri object.

---

## **Best Practices**

### **DRY (Don't Repeat Yourself)**
Avoid code duplication by extracting common logic.

### **Helper methods**
Private methods that encapsulate reusable logic.

```dart
Future<sql.Database> _getDatabase() async {
  // Reusable database setup
  final dbPath = await sql.getDatabasesPath();
  return sql.openDatabase(...);
}
```

### **Error handling**
Using try-catch to handle async errors gracefully.

### **Loading states**
Show feedback while async operations are in progress.

```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}
```

### **User feedback**
Provide visual cues (spinners, tooltips, hints) for better UX.

```dart
tooltip: 'Confirm Location',
```

---

## **Project Summary**

This Favourite Places project covered a full-stack mobile development workflow including:

- ✅ **UI** - Beautiful, responsive interfaces with custom styling
- ✅ **State Management** - Riverpod for reactive state updates
- ✅ **Local Storage** - SQLite database for persistent data
- ✅ **External APIs** - HTTP requests for geocoding
- ✅ **Camera** - Image capture and file management
- ✅ **GPS** - Location services and permissions
- ✅ **Maps** - Interactive maps with markers and controls

**Key Skills Developed:**
- Async programming patterns
- Database design and operations
- File system manipulation
- API integration
- Permission handling
- Complex UI layouts
- Navigation patterns
- Error handling
- Code organization and best practices

---

*Generated: March 14, 2026*
