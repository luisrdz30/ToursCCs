import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/scheduled_tour_dto.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _iniciarRecorrido(ScheduledTourDto trip) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('scheduled_tours').doc(trip.id).update({
        'status': 'Active',
      });
      if (mounted) {
        context.push('/chofer/active-trip', extra: trip.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar recorrido: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'Detalle del Viaje',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('scheduled_tours').doc(widget.tripId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Viaje no encontrado'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final trip = ScheduledTourDto.fromJson(data, id: snapshot.data!.id);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppTheme.surfaceVariant,
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    trip.tourTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(Icons.schedule, trip.startTime),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.circle, trip.status),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.directions_bus, 'Unidad U-04'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este viaje incluye el recorrido completo según el itinerario establecido. Asegúrate de confirmar a todos los pasajeros antes de iniciar la ruta.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Botón Lista de Pasajeros
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/chofer/passengers/${trip.id}');
                      },
                      icon: const Icon(Icons.people_outline, color: AppTheme.primary),
                      label: const Text(
                        'Lista de Pasajeros',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón Iniciar Recorrido
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _iniciarRecorrido(trip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar Recorrido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}