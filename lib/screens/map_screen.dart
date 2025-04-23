import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
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
  final PopupController _popupController = PopupController();
  late List<Marker> markers = [];
  late List<ILocation> locations = [];
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
                    final fetchedLocations = getLocations(
                      mapaController,
                      _textController,
                      _popupController,
                    );
                    fetchedLocations.then((value) {
                      setState(() {
                        markers = value['markers'];
                        locations = value['locations'];
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
                PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupController,
                    markers: markers,
                    markerTapBehavior: MarkerTapBehavior.togglePopup(),
                    popupBuilder: (BuildContext context, Marker marker) {
                      final LatLng position = marker.point;
                      final ILocation? data = locations.firstWhere(
                        (location) =>
                            location.ubicacion.coordinates[1] ==
                                position.latitude &&
                            location.ubicacion.coordinates[0] ==
                                position.longitude,
                        orElse:
                            () => ILocation(
                              id: 'Unknown',
                              nombre: 'Unknown',
                              address: 'Unknown',
                              phone: 'Unknown',
                              rating: 0.0,
                              serviceType: [],
                              schedule: [],
                              business: 'Unknown',
                              workers: [],
                              isDeleted: false,
                              ubicacion: GeoJSONPoint(
                                type: 'Point',
                                coordinates: [0.0, 0.0],
                              ),
                            ),
                      );

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Location Name: ${data?.nombre ?? 'Unknown'}\n'
                            'Address: ${data?.address ?? 'Unknown'}\n'
                            'Phone: ${data?.phone ?? 'Unknown'}\n',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Marker> buildMarkersFromGeoJSON(
  List<ILocation> points,
  PopupController _popupController,
) {
  return points.map((point) {
    return Marker(
      point: LatLng(
        point.ubicacion.coordinates[1],
        point.ubicacion.coordinates[0],
      ), // [lat, lon]
      width: 80,
      height: 80,
      builder:
          (ctx) => GestureDetector(
            onTap:
                () => _popupController.showPopupsOnlyFor([
                  Marker(
                    point: LatLng(
                      point.ubicacion.coordinates[1],
                      point.ubicacion.coordinates[0],
                    ),
                    width: 80,
                    height: 80,
                    builder:
                        (ctx) => Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                  ),
                ]),
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
    );
  }).toList();
}

Future<Map<String, dynamic>> getLocations(
  MomentumMapController.MapController mapaController,
  TextEditingController textController,
  PopupController _popupController,
) async {
  await mapaController.getAllLocationsByServiceType(textController.text);
  List<GeoJSONPoint> resultingPoints = [];
  List<ILocation> locations = mapaController.locations;
  for (var location in locations) {
    resultingPoints.add(location.ubicacion);
  }
  final List<Marker> markers = buildMarkersFromGeoJSON(
    locations,
    _popupController,
  );
  return {'locations': locations, 'markers': markers};
}
