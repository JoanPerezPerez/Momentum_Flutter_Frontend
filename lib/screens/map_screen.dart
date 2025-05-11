import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:async';

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
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  ILocation? selectedLocation;
  @override
  void initState() {
    super.initState();
    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map")),
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
                initialCenter: LatLng(0, 0),
                initialZoom: 5.0,
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
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        final LatLng position = marker.point;
                        selectedLocation = locations.firstWhere(
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
                        if (selectedLocation?.nombre == 'Unknown')
                          return SizedBox.shrink();
                        return SizedBox(
                          width: 300,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //PER SI VOLEM POSAR UNA FOTO EN LES LOCATION
                                /*                                 ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    selectedLocation?.imageUrl ?? 'https://via.placeholder.com/300x150.png?text=No+Image',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ), */
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedLocation?.nombre ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${selectedLocation?.rating.toStringAsFixed(1)}',
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 6),
                                      Text(
                                        selectedLocation?.address ?? 'Unknown',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text('Tel: ${selectedLocation?.phone}'),

                                      SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          ActionChip(
                                            avatar: Icon(
                                              Icons.calendar_month,
                                              size: 18,
                                            ),
                                            label: Text('Request appointment'),
                                            onPressed: () {},
                                          ),
                                          ActionChip(
                                            avatar: Icon(Icons.call, size: 18),
                                            label: Text('Call'),
                                            onPressed: () {
                                              //FALTARIA ACCEDIR A LA FUNCIONALITAT DEL TELÈFON
                                            },
                                          ),
                                          ActionChip(
                                            avatar: Icon(
                                              Icons.message,
                                              size: 18,
                                            ),
                                            label: Text('Send message'),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        /*   return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Location Name: ${selectedLocation?.nombre ?? 'Unknown'}\n'
                              'Address: ${selectedLocation?.address ?? 'Unknown'}\n'
                              'Phone: ${selectedLocation?.phone ?? 'Unknown'}\n',
                            ),
                          ),
                        );
                       */
                      },
                    ),
                  ),
                ),
                CurrentLocationLayer(
                  alignPositionStream: _alignPositionStreamController.stream,
                  alignPositionOnUpdate: _alignPositionOnUpdate,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        // Align the location marker to the center of the map widget
                        // on location update until user interact with the map.
                        setState(
                          () => _alignPositionOnUpdate = AlignOnUpdate.always,
                        );
                        // Align the location marker to the center of the map widget
                        // and zoom the map to level 18.
                        _alignPositionStreamController.add(18);
                      },
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
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
      child: GestureDetector(
        onTap:
            () => _popupController.showPopupsOnlyFor([
              Marker(
                point: LatLng(
                  point.ubicacion.coordinates[1],
                  point.ubicacion.coordinates[0],
                ),
                width: 80,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin, color: Colors.red, size: 40),
                    Text(
                      point.nombre,
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_pin, color: Colors.red, size: 40),
            Text(
              point.nombre,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
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
