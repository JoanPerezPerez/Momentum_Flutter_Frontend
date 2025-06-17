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
import 'package:momentum/controllers/navigator_controller.dart';
import 'package:momentum/widgets/business_map_popup.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';


class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final PopupController popupController = PopupController();
  final TextEditingController _textController = TextEditingController();
  final MomentumMapController.MapController mapaController = Get.find();
  final navigatorController = Get.find<NavigationController>();
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

  @override
  void initState() {
    super.initState();
    _alignPositionOnUpdate = AlignOnUpdate.never;
    _alignPositionStreamController = StreamController<double?>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorController.selectedIndex.value != 4) {
        mapaController.clearData();
      }
    });
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Colors.white,
          appBar: navigatorController.selectedIndex.value == 4
              ? AppBar(
                  title: const Text('Mapa'),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                )
              : null,
          body: Column(
            children: [
              const SizedBox(height: 40),
              Obx(() => navigatorController.selectedIndex.value != 4
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return locationServiceType.values
                                    .map((e) => e.description)
                                    .where((desc) => desc
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (String selected) {
                                _textController.text = selected;
                                mapaController.getLocations(selected, popupController);
                              },
                              fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController controller,
                                FocusNode focusNode,
                                VoidCallback onEditingComplete,
                              ) {
                                controller.addListener(() {
                                  _textController.text = controller.text;
                                  _textController.selection = controller.selection;
                                });

                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: InputDecoration(
                                    hintText: 'Quin servei vols trobar?',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                mapaController.getLocations(
                                  _textController.text,
                                  popupController,
                                );
                              },
                              child: const Icon(Icons.search, size: 24, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
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
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    PopupMarkerLayerWidgetReactive(
                      popupController: popupController,
                      mapaController: mapaController,
                    ),
                    CurrentLocationLayer(
                      alignPositionStream: _alignPositionStreamController.stream,
                      alignPositionOnUpdate: _alignPositionOnUpdate,
                      style: LocationMarkerStyle(
                        marker: const DefaultLocationMarker(
                          color: Colors.blue,
                          child: Icon(Icons.navigation, size: 16, color: Colors.white),
                        ),
                        accuracyCircleColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            setState(() => _alignPositionOnUpdate = AlignOnUpdate.once);
                            _alignPositionStreamController.add(18);
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const MomentumBottomNavBar(),
        ));
  }
}
