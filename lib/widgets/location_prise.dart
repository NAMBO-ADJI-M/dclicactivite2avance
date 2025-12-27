import 'package:dclicactivite2avance/modele/location.dart';
import 'package:dclicactivite2avance/vue/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationPrise extends StatefulWidget {
  const LocationPrise({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  final void Function(EndroitLocation location) onLocationSelected;
  final EndroitLocation? initialLocation;

  @override
  State<LocationPrise> createState() {
    return _LocationPriseState();
  }
}

class _LocationPriseState extends State<LocationPrise> {
  EndroitLocation? _pickedLocation;
  var _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _pickedLocation = widget.initialLocation;
    } else {
      _getCurrentLocation(); // La détection se lance automatiquement si pas de valeur initiale
    }
  }

  @override
  void didUpdateWidget(LocationPrise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation) {
      setState(() {
        _pickedLocation = widget.initialLocation;
      });
    }
  }

  void _getCurrentLocation() async {
    if (_isGettingLocation) return;

    if (mounted) {
      setState(() {
        _isGettingLocation = true;
      });
    }

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isGettingLocation = false);
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) setState(() => _isGettingLocation = false);
        return;
      }
    }

    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        if (mounted) setState(() => _isGettingLocation = false);
        return;
      }
      _saveLocation(lat, lng);
    } catch (e) {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _viewOnMap() {
    if (_pickedLocation == null) {
      return; // Ne fait rien si aucune position n'est encore détectée
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          location: _pickedLocation!,
          isSelecting: false, // Ouvre la carte en mode consultation
        ),
      ),
    );
  }

  void _saveLocation(double latitude, double longitude) {
    if (!mounted) return;
    final location = EndroitLocation(latitude: latitude, longitude: longitude);
    setState(() {
      _pickedLocation = location;
      _isGettingLocation = false;
    });
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'Détection de la position...',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      previewContent = Text(
        'Lat: ${_pickedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_pickedLocation!.longitude.toStringAsFixed(6)}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withAlpha(51),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Voir sur la carte'),
              onPressed: _viewOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
