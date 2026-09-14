import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TouristDetailScreen extends StatefulWidget {
  final String touristId;
  const TouristDetailScreen({super.key, required this.touristId});

  @override
  State<TouristDetailScreen> createState() => _TouristDetailScreenState();
}

class _TouristDetailScreenState extends State<TouristDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _confirmarAbordaje() async {
    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser!.uid;
      
      // Encontrar el viaje activo del chofer (o el programado más cercano)
      final tripsSnapshot = await _firestore
          .collection('scheduled_tours')
          .where('driverId', isEqualTo: uid)
          .orderBy('date')
          .limit(1)
          .get();

      if (tripsSnapshot.docs.isEmpty) {
        throw Exception('No tienes viajes asignados activos');
      }

      final activeTripId = tripsSnapshot.docs.first.id;

      // Buscar al pasajero en la subcolección
      final query = await _firestore
          .collection('scheduled_tours')
          .doc(activeTripId)
          .collection('passengers')
          .where('touristId', isEqualTo: widget.touristId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Intentar actualizar directamente si el documentId de subcoleccion = touristId
        await _firestore
            .collection('scheduled_tours')
            .doc(activeTripId)
            .collection('passengers')
            .doc(widget.touristId)
            .update({'hasBoarded': true});
      } else {
        await query.docs.first.reference.update({'hasBoarded': true});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abordaje confirmado exitosamente.')));
        context.go('/chofer/passengers/$activeTripId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _buildProfileHero(),
                        const SizedBox(height: 24),
                        _buildContactCard(),
                        const SizedBox(height: 16),
                        _buildMedicalNotesCard(),
                        const SizedBox(height: 100), // Padding for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Sticky Bottom Action
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.surface,
                      AppTheme.surface.withOpacity(0.0),
                    ],
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _confirmarAbordaje,
                    icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.onPrimary, strokeWidth: 2))
                        : const Icon(Icons.check_circle, color: AppTheme.onPrimary),
                    label: Text(
                      _isLoading ? 'Confirmando...' : 'Confirmar Abordaje',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppTheme.primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => context.go('/chofer/passengers/t1'),
          ),
          const Text(
            'PASAJERO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.more_vert, color: AppTheme.onSurface),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildProfileHero() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryContainer, AppTheme.tertiaryContainer],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(39, 101, 124, 0.15),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDmij1El-vPLGx82j-SahSK1aEq6wHm8YRRaJd9oNTGr3--3UbF8OTqfCh5mfYGHEvwOTpaVkRa2mw9B61usCF0yzWylBQZJMlXBQZi1jRyN0dczCa-Zci0acdhi7blmtLSjrSeFIiCD136DqTs0JVrQY4KgqXOCBM1tENiHcmzVt_Kyz7k52LjA7JKRRkNCJP0kGsF6hrHhSn3pHq_6WwHPp5xE5rT_bQ9sOzIGcdrYFcgB4AKkYJuCQ',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified, color: AppTheme.onPrimary, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Elena Rostova',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.public, size: 18, color: AppTheme.tertiary),
              SizedBox(width: 8),
              Text(
                'Polonia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, 0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.perm_contact_calendar, color: AppTheme.secondary),
              SizedBox(width: 8),
              Text(
                'Información de Contacto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TELÉFONO REGISTRADO',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '+48 500 123 456',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.content_copy, color: AppTheme.secondary, size: 20),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppTheme.outlineVariant), // Simulated dashed line with plain divider for now
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PUNTO DE ENCUENTRO',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hotel Central, Lobby Principal',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.map_outlined, color: AppTheme.secondary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalNotesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(186, 26, 26, 0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Transform.rotate(
              angle: 0.2, // ~12 degrees
              child: Icon(
                Icons.medical_information,
                size: 120,
                color: AppTheme.onErrorContainer.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.onErrorContainer),
                  SizedBox(width: 8),
                  Text(
                    'Notas Importantes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag('Alergia Alimentaria'),
                  _buildTag('Movilidad Reducida'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Pasajera alérgica severa a los mariscos. Requiere asistencia leve para subir peldaños altos. Asiento asignado: Fila 1, Ventana por comodidad.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onErrorContainer,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.onErrorContainer.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.onErrorContainer,
        ),
      ),
    );
  }
}