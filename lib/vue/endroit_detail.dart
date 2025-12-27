import 'dart:convert';
import 'dart:io';

import 'package:dclicactivite2avance/modele/endroit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class EndroitDetail extends StatefulWidget {
  const EndroitDetail({super.key, required this.endroit});

  final Endroit endroit;

  @override
  State<EndroitDetail> createState() => _EndroitDetailState();
}

class _EndroitDetailState extends State<EndroitDetail> {
  late final MapController _mapController;
  List<LatLng> _routePoints = [];
  LocationData? _userLocation;
  bool _isLoading = true; // On commence en état de chargement

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getRoute(); // Appel automatique au chargement de l'écran
  }

  Future<void> _getRoute() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _routePoints = []; // On nettoie l'ancien itinéraire
    });

    try {
      // 1. Obtenir la position actuelle de l'utilisateur avec HAUTE PRÉCISION
      Location location = Location();
      await location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
      _userLocation = await location.getLocation();
      if (!mounted) return;

      if (_userLocation?.latitude == null || _userLocation?.longitude == null) {
        throw Exception('Localisation invalide');
      }

      // 2. Appeler l'API de routage (OSRM)
      final userLat = _userLocation!.latitude!;
      final userLng = _userLocation!.longitude!;
      final destLat = widget.endroit.location.latitude;
      final destLng = widget.endroit.location.longitude;

      final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$userLng,$userLat;$destLng,$destLat?overview=full&geometries=geojson');
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
        
        setState(() {
          _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });

        // 3. Ajuster la vue de la carte pour montrer les deux points
        final bounds = LatLngBounds.fromPoints([
          LatLng(userLat, userLng),
          LatLng(destLat, destLng),
        ]);
        _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));

      } else {
        throw Exception('Erreur du service de routage.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Impossible de calculer l'itinéraire: ${e.toString()}"),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.endroit.nom),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Hero(
            tag: widget.endroit.id, // Tag unique pour l'animation
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.file(
                File(widget.endroit.image),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.endroit.location.latitude, widget.endroit.location.longitude),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.jide.dclicactivite2avance',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Marqueur pour la destination
                    Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(widget.endroit.location.latitude, widget.endroit.location.longitude),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                    // Marqueur pour la position de l'utilisateur
                    if (_userLocation != null)
                      Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _getRoute, // Désactiver pendant le chargement
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
