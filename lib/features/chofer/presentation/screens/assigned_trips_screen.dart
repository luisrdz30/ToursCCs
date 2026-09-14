import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/scheduled_tour_dto.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignedTripsScreen extends StatefulWidget {
  const AssignedTripsScreen({super.key});

  @override
  State<AssignedTripsScreen> createState() => _AssignedTripsScreenState();
}

class _AssignedTripsScreenState extends State<AssignedTripsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ScheduledTourDto>> _getTripsStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('scheduled_tours')
        .where('driverId', isEqualTo: uid)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduledTourDto.fromJson(doc.data(), id: doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<List<ScheduledTourDto>>(
                stream: _getTripsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return const Center(child: Text('No tienes viajes asignados.'));
                  }

                  // El primer viaje será el "Hero Trip"
                  final heroTrip = trips.first;
                  final upcomingTrips = trips.skip(1).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(trips.length),
                        const SizedBox(height: 40),
                        _buildHeroTripCard(context, heroTrip),
                        const SizedBox(height: 40),
                        if (upcomingTrips.isNotEmpty) ...[
                          _buildUpcomingTripsHeader(),
                          const SizedBox(height: 24),
                          ...upcomingTrips.map((trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUpcomingTripItem(
                              context: context,
                              title: trip.tourTitle,
                              time: trip.startTime,
                              pax: '--- pax', // Calcularemos pax en el stream si es necesario
                              tripId: trip.id,
                            ),
                          )).toList(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => context.push('/chofer/profile'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surfaceContainerHighest, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDC0A0DhH8OLoBPmHsTJAlS-4kxpiv7HzjURy2986Hh7CAX72U5rYee7fGuQGIXh5LIDoKv2t8wD6ZuVDskw20TOg1xq_YSP0P1z1WOWwKJAMUW7-zqVm0qTgooysMmCjMVI0ibPTzBRaNsJEqlYTXhRNbZV6jtnZmrbUzr-aa8Zq1ylcYHAyhWEqZk8yAKAye5SycVlooVzbj9-Tde-qGoQ36efu4xlPFewVu_jsIQLfCv7PfodJfd2Q',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(
            'Zizi\'s Tour',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.onSurfaceVariant),
            onPressed: () => context.push('/chofer/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hola, Chofer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tienes \$count viajes asignados para hoy.',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.onSurfaceVariant,
            fontFamily: 'Be Vietnam Pro',
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTripCard(BuildContext context, ScheduledTourDto trip) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, 0.08),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuC5IAdilrRTQnw8aYALwAkyhVA1osGjYsZYKoBnO6TX1SIGJMkzG9hjwhh50AXVUHK-s2Y1qHlkcWLMqC-8j9ZtiqbvIoUbaVQopu6ddbm0cv7EjadeirVA19WkkpBBWKorf414KZRT2B1Ko2cKlTNKRF73g6qy55btI0YM3WaXJCF2ZTKdTgWUQA0SnM-OMhcV5pOmxxEVzmTTHgs9dNcFiZqbskVrjnWr8GCEgow6QZnBW6oVmlnk9Q',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.tourTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 18, color: AppTheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                trip.startTime,
                                style: const TextStyle(color: AppTheme.secondary, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 10, color: AppTheme.onSecondaryContainer),
                    SizedBox(width: 4),
                    Text(
                      'PRÓXIMO A SALIR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group, color: AppTheme.onSecondary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pasajeros', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                        Text('12 / 15', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                      ],
                    ),
                  ],
                ),
                Container(width: 1, height: 32, color: AppTheme.outlineVariant),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_bus, color: AppTheme.onTertiaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Unidad', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                        Text('U-04', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/chofer/passengers/\${trip.id}');
              },
              icon: const Icon(Icons.play_circle_fill, color: AppTheme.onPrimary),
              label: const Text(
                'Iniciar Viaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTripsHeader() {
    return const Text(
      'Próximos en el día',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.onSurface,
      ),
    );
  }

  Widget _buildUpcomingTripItem({
    required BuildContext context,
    required String title,
    required String time,
    required String pax,
    String? imageUrl,
    IconData? iconData,
    required String tripId,
  }) {
    return InkWell(
      onTap: () {
        context.go('/chofer/trip/$tripId');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: iconData != null
                  ? Icon(iconData, color: AppTheme.secondary.withOpacity(0.5))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(width: 12),
                      const Icon(Icons.group, size: 14, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(pax, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 78, 100, 0.15),
            blurRadius: 10,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.route, 'Viajes', true, () {}),
          _buildNavItem(Icons.qr_code_scanner, 'Escanear', false, () {
            context.go('/chofer/scan');
          }),
          _buildNavItem(Icons.group, 'Pasajeros', false, () {
            context.go('/chofer/passengers/t1');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.secondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}