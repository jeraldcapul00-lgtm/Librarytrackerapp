// lib/screens/library_map_screen.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ─── ACLC MANDAUE LIBRARY COORDINATES ────────────────────────────────────────
const LatLng _libraryPos = LatLng(10.3336, 123.9418);
const String _libraryName = 'ACLC MANDAUE';

class LibraryMapScreen extends StatefulWidget {
  const LibraryMapScreen({super.key});

  @override
  State<LibraryMapScreen> createState() => _LibraryMapScreenState();
}

class _LibraryMapScreenState extends State<LibraryMapScreen> {
  final MapController _mapController = MapController();

  LatLng? _userPos;
  List<LatLng> _routePoints = [];
  double? _distanceKm;
  bool _locationLoading = true;
  bool _routeLoading = false;
  String? _locationError;
  bool _showLibraryPopup = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // ─── LOCATION ─────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied.';
            _locationLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission permanently denied. Please enable in settings.';
          _locationLoading = false;
        });
        return;
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled.';
          _locationLoading = false;
        });
        return;
      }

      // Get position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (!mounted) return;

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userPos = userLatLng;
        _distanceKm = _haversineDistance(userLatLng, _libraryPos);
        _locationLoading = false;
      });

      // Center map between user and library
      _fitBounds();

      // Fetch walking route
      await _fetchRoute(userLatLng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Could not get location: ${e.toString()}';
        _locationLoading = false;
      });
    }
  }

  void _fitBounds() {
    if (_userPos == null) return;
    try {
      final bounds = LatLngBounds.fromPoints([_userPos!, _libraryPos]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    } catch (_) {}
  }

  // ─── ROUTE via OSRM ───────────────────────────────────────────────────────

  Future<void> _fetchRoute(LatLng from) async {
    setState(() => _routeLoading = true);
    try {
      final url =
          'https://router.project-osrm.org/route/v1/walking/'
          '${from.longitude},${from.latitude};'
          '${_libraryPos.longitude},${_libraryPos.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes']?[0]?['geometry']?['coordinates'] as List?;
        if (coords != null) {
          final points = coords
              .map(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
          if (mounted) {
            setState(() {
              _routePoints = points;
              // Update distance from OSRM (more accurate)
              final meters = data['routes']?[0]?['distance'] as num?;
              if (meters != null) {
                _distanceKm = meters / 1000;
              }
            });
          }
        }
      }
    } catch (_) {
      // Route failed silently — straight line still shows
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  // ─── HAVERSINE DISTANCE ───────────────────────────────────────────────────

  double _haversineDistance(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final hav =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(a.latitude)) *
            math.cos(_toRad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(hav), math.sqrt(1 - hav));
  }

  double _toRad(double deg) => deg * math.pi / 180;

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header (matches web)
        Container(
          width: double.infinity,
          color: const Color(0xFF1e3a2e),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '📍 Real Geolocation Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_routeLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Color(0xFF52b788),
                        strokeWidth: 2,
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _initLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Color(0xFF52b788),
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Refresh',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Map
        Expanded(
          child: _locationLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1e3a2e)),
                      SizedBox(height: 16),
                      Text(
                        'Getting your location...',
                        style: TextStyle(
                          color: Color(0xFF6b7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : _locationError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 48,
                          color: Color(0xFF9ca3af),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _locationError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1e3a2e),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _initLocation,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // ── FlutterMap
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _userPos ?? _libraryPos,
                        initialZoom: 14,
                        onTap: (_, __) =>
                            setState(() => _showLibraryPopup = false),
                      ),
                      children: [
                        // OSM tile layer
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.librarytrackerapp',
                        ),

                        // Route polyline (green like web)
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: const Color(0xFF1e7a34),
                                strokeWidth: 4.5,
                              ),
                            ],
                          )
                        else if (_userPos != null)
                          // Fallback straight line
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [_userPos!, _libraryPos],
                                color: const Color(0xFF1e7a34),
                                strokeWidth: 3,
                              ),
                            ],
                          ),

                        // Markers
                        MarkerLayer(
                          markers: [
                            // Library marker (red like web)
                            Marker(
                              point: _libraryPos,
                              width: 40,
                              height: 50,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _showLibraryPopup = !_showLibraryPopup,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '🏫',
                                            style: TextStyle(fontSize: 9),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            _libraryName,
                                            style: const TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1e3a2e),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // User marker (blue like web)
                            if (_userPos != null)
                              Marker(
                                point: _userPos!,
                                width: 36,
                                height: 44,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        '📍 You',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1e3a2e),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Color(0xFF2563EB),
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // ── Recenter button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _fitBounds,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.fit_screen,
                            size: 18,
                            color: Color(0xFF1e3a2e),
                          ),
                        ),
                      ),
                    ),

                    // ── Zoom buttons
                    Positioned(
                      top: 56,
                      right: 12,
                      child: Column(
                        children: [
                          _zoomBtn(Icons.add, () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          }),
                          const SizedBox(height: 4),
                          _zoomBtn(Icons.remove, () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
        ),

        // ── Info bar at bottom (matches web)
        if (!_locationLoading && _locationError == null)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_userPos != null) ...[
                  _infoRow(
                    '📍',
                    'Latitude: ${_userPos!.latitude.toStringAsFixed(7)}',
                  ),
                  _infoRow(
                    '📍',
                    'Longitude: ${_userPos!.longitude.toStringAsFixed(7)}',
                  ),
                ],
                _infoRow('🏫', 'Library: ${'Mandaue Maguikay'}'),
                if (_distanceKm != null)
                  _infoRow(
                    '📏',
                    'Distance: ${_distanceKm!.toStringAsFixed(2)} km',
                  ),
                if (_routeLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFF1e3a2e),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Calculating route...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }
}
