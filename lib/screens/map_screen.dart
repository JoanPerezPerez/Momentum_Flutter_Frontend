import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;
import 'package:momentum/models/location_model.dart'; // Use the GeoJSONPoint from this file

class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late List<Marker> markers = [];
  final TextEditingController _textController = TextEditingController();
  final MomentumMapController.MapController mapaController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa amb OSM")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Which store would you like to find?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    mapaController.locations.clear();
                    final locations = getLocations(
                      mapaController,
                      _textController,
                    );
                    locations.then((value) {
                      setState(() {
                        markers = value;
                      });
                    });
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(41.2754, 1.9863),
                zoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Marker> buildMarkersFromGeoJSON(List<GeoJSONPoint> points) {
  return points.map((point) {
    return Marker(
      point: LatLng(point.coordinates[1], point.coordinates[0]), // [lat, lon]
      width: 80,
      height: 80,
      builder: (ctx) => Icon(Icons.location_pin, color: Colors.red, size: 40),
    );
  }).toList();
}

Future<List<Marker>> getLocations(
  MomentumMapController.MapController mapaController,
  TextEditingController textController,
) async {
  await mapaController.getAllLocationsByServiceType(textController.text);
  List<GeoJSONPoint> resultingPoints = [];
  for (var location in mapaController.locations) {
    resultingPoints.add(location.ubicacion);
  }
  return buildMarkersFromGeoJSON(resultingPoints);
}
