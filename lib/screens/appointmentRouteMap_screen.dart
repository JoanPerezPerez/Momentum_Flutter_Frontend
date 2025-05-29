import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:momentum/services/mapa_service.dart';

class AppointmentRouteMapScreen extends StatefulWidget {
  final String calendarId;
  const AppointmentRouteMapScreen({required this.calendarId, Key? key}) : super(key: key);
  @override
  State<AppointmentRouteMapScreen> createState() => _AppointmentRouteMapScreenState();
}

class _AppointmentRouteMapScreenState extends State<AppointmentRouteMapScreen> {
  final PopupController popupController = PopupController();
  final List<Marker> _appointmentMarkers = [];
  final List<LatLng> _routePoints = [];
  final List<LatLng> _currentToFirstRoutePoints = [];
  final Map<String, ILocation> _locationsCache = {};
  final List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  LatLng? _currentLocation;
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

  @override
  void initState() {
    super.initState();
    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    _loadAppointments();
  }

  @override
  void dispose() {
    _alignPositionStreamController.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateCurrentToFirstRoute();
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _updateCurrentToFirstRoute() {
    _currentToFirstRoutePoints.clear();
    if (_currentLocation != null && _routePoints.isNotEmpty) {
      _currentToFirstRoutePoints.add(_currentLocation!);
      _currentToFirstRoutePoints.add(_routePoints.first);
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final today = DateTime.now();
      final appointments = await CalendarService().getAppointmentsByDate(
        widget.calendarId,
        today.toIso8601String().substring(0, 10),
      );

      appointments.sort((a, b) => a.inTime.compareTo(b.inTime));
      _appointments.clear();
      _appointments.addAll(appointments);

      _appointmentMarkers.clear();
      _routePoints.clear();

      for (var appointment in appointments) {
        final locId = appointment.locationId;
        if (locId != null && !_locationsCache.containsKey(locId)) {
          final location = await MapService.getLocationById(locId);
          _locationsCache[locId] = location;
        }
        final location = _locationsCache[locId];
        if (location != null) {
          final coords = LatLng(
            location.ubicacion.coordinates[1],
            location.ubicacion.coordinates[0],
          );
          _routePoints.add(coords);
          _appointmentMarkers.add(
            Marker(
              point: coords,
              width: 40,
              height: 40,
              child: Icon(Icons.schedule, size: 36, color: Colors.orange),
            ),
          );
        }
      }

      // Obtener la ubicación actual después de cargar las citas
      await _getCurrentLocation();

    } catch (e) {
      print('Error loading appointments: $e');
      Get.snackbar('Error', 'No se pudieron cargar las citas');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ruta de cites')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _routePoints.isNotEmpty
                    ? _routePoints.first
                    : LatLng(41.3888, 2.159), // Default to Barcelona if empty
                initialZoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.momentum.app',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      // Línea entre las citas (roja)
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                      // Línea desde ubicación actual al primer destino (azul)
                      if (_currentToFirstRoutePoints.isNotEmpty)
                        Polyline(
                          points: _currentToFirstRoutePoints,
                          color: Colors.red,
                          strokeWidth: 3,
                          
                        ),
                    ],
                  ),
                PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    popupController: popupController,
                    markers: _appointmentMarkers,
                    markerTapBehavior: MarkerTapBehavior.togglePopup(),
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        final LatLng position = marker.point;
                        final AppointmentModel? selectedAppointment = _appointments.firstWhereOrNull(
                          (appointment) {
                            final locId = appointment.locationId;
                            if (locId == null) return false;
                            final location = _locationsCache[locId];
                            if (location == null) return false;
                            // Usar tolerancia para la comparación de coordenadas
                            final double tolerance = 0.0001;
                            final double latDiff = (location.ubicacion.coordinates[1] - position.latitude).abs();
                            final double lngDiff = (location.ubicacion.coordinates[0] - position.longitude).abs();
                            return latDiff < tolerance && lngDiff < tolerance;
                          },
                        );

                        if (selectedAppointment == null) {
                          return const SizedBox.shrink();
                        }

                        final location = _locationsCache[selectedAppointment.locationId];

                        return SizedBox(
                          width: 300,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedAppointment.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${selectedAppointment.inTime.hour}:${selectedAppointment.inTime.minute.toString().padLeft(2, '0')}',
                                      ),
                                    ],
                                  ),
                                  if (selectedAppointment.description != null && selectedAppointment.description!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      selectedAppointment.description!,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                  if (location != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      location.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      location.address,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text('Tel: ${location.phone}'),
                                  ],
                                  const SizedBox(height: 10)
                                  
                                ],
                              ),
                            ),
                          ),
                        );
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
                        setState(
                          () => _alignPositionOnUpdate = AlignOnUpdate.always,
                        );
                        _alignPositionStreamController.add(18);
                      },
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}