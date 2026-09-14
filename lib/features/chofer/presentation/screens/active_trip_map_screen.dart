import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';

class ActiveTripMapScreen extends StatefulWidget {
  final String tripId;

  const ActiveTripMapScreen({super.key, required this.tripId});

  @override
  State<ActiveTripMapScreen> createState() => _ActiveTripMapScreenState();
}

class _ActiveTripMapScreenState extends State<ActiveTripMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentStopIndex = 0;
  bool _isEnRouteToDestination = false;
  bool _isSharingLocation = false;
  StreamSubscription<Position>? _positionStream;

  final List<Map<String, dynamic>> _stops = [
    {
      'hotel': 'Hotel Plaza Grande',
      'pax': 2,
      'status': 'pending', // pending, picked_up
      'eta': '5 min',
    },
    {
      'hotel': 'Casa Gangotena',
      'pax': 4,
      'status': 'pending',
      'eta': '12 min',
    },
    {
      'hotel': 'Hotel Carlota',
      'pax': 2,
      'status': 'pending',
      'eta': '20 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startLocationSharing();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationSharing() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicios de ubicación deshabilitados.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permisos denegados.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permisos denegados permanentemente.')));
      return;
    }

    setState(() => _isSharingLocation = true);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      _updateLocationInFirestore(position);
    });
  }

  Future<void> _updateLocationInFirestore(Position pos) async {
    try {
      await _firestore.collection('scheduled_tours').doc(widget.tripId).update({
        'currentLocation': GeoPoint(pos.latitude, pos.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  void _markStopAsPickedUp(int index) {
    setState(() {
      _stops[index]['status'] = 'picked_up';
      if (index + 1 < _stops.length) {
        _currentStopIndex = index + 1;
        // Simular notificación a los siguientes turistas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificando turistas en ${_stops[_currentStopIndex]['hotel']}...'),
            backgroundColor: AppTheme.primary,
          ),
        );
      } else {
        // Todos recogidos
        _isEnRouteToDestination = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'En Ruta',
          style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mapa Simulado
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop', // Mapa ficticio
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.location_on, size: 64, color: AppTheme.primary),
                  Positioned(
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed, color: AppTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _isEnRouteToDestination ? 'En camino al destino' : 'Compartiendo ubicación en vivo',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Panel Inferior de Paradas
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, offset: Offset(0, -4), blurRadius: 16),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paradas de Recogida',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                        ),
                        if (_isEnRouteToDestination)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
                            child: const Text('Completado', style: TextStyle(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _stops.length,
                      itemBuilder: (context, index) {
                        final stop = _stops[index];
                        final isCurrent = index == _currentStopIndex && !_isEnRouteToDestination;
                        final isPickedUp = stop['status'] == 'picked_up';

                        return _buildStopItem(
                          hotel: stop['hotel'],
                          pax: stop['pax'],
                          eta: stop['eta'],
                          isCurrent: isCurrent,
                          isPickedUp: isPickedUp,
                          onPickedUp: () => _markStopAsPickedUp(index),
                        );
                      },
                    ),
                  ),
                  if (_isEnRouteToDestination)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Terminar viaje o redirigir a otro lado
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegando al primer destino...')));
                          },
                          icon: const Icon(Icons.navigation, color: AppTheme.onPrimary),
                          label: const Text('Navegar al Destino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem({
    required String hotel,
    required int pax,
    required String eta,
    required bool isCurrent,
    required bool isPickedUp,
    required VoidCallback onPickedUp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.primaryContainer.withValues(alpha: 0.3) : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppTheme.primary : AppTheme.outlineVariant.withValues(alpha: 0.5),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPickedUp ? Colors.green : (isCurrent ? AppTheme.primary : AppTheme.surfaceContainerHighest),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPickedUp ? Icons.check : Icons.hotel,
              color: isPickedUp || isCurrent ? Colors.white : AppTheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPickedUp ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
                    decoration: isPickedUp ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pax Pasajeros • ETA: $eta',
                  style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (isCurrent)
            ElevatedButton(
              onPressed: onPickedUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Recogido', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
