import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PassengerListScreen extends StatefulWidget {
  final String tripId;
  const PassengerListScreen({super.key, required this.tripId});

  @override
  State<PassengerListScreen> createState() => _PassengerListScreenState();
}

class _PassengerListScreenState extends State<PassengerListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('scheduled_tours')
                    .doc(widget.tripId)
                    .collection('passengers')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final passengers = snapshot.data?.docs ?? [];
                  
                  if (passengers.isEmpty) {
                    return const Center(child: Text('No hay pasajeros registrados aún.'));
                  }

                  final boardedCount = passengers.where((doc) => doc['hasBoarded'] == true).length;
                  final totalCount = passengers.length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(boardedCount, totalCount),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        ...passengers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPassengerCard(
                              context: context,
                              touristId: doc.id,
                              name: data['touristName'] ?? 'Desconocido',
                              details: 'Documento: ${data['documentId'] ?? '---'}',
                              isBoarded: data['hasBoarded'] ?? false,
                              initials: (data['touristName'] as String?)?.substring(0, 2).toUpperCase() ?? '??',
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 100), // Padding for FAB
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppTheme.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'Zizi\'s Tour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.onSurfaceVariant),
                onPressed: () => context.push('/chofer/notifications'),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int boarded, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estado del Abordaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$boarded',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ $total pasajeros',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: total > 0 ? boarded / total : 0,
                  backgroundColor: AppTheme.surfaceContainerHighest,
                  color: AppTheme.primary,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                total > 0 ? '${((boarded / total) * 100).toInt()}%' : '0%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o asiento...',
          hintStyle: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppTheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPassengerCard({
    required BuildContext context,
    required String touristId,
    required String name,
    required String details,
    required bool isBoarded,
    String? imageUrl,
    String? initials,
  }) {
    return InkWell(
      onTap: () {
        context.go('/chofer/tourist/$touristId');
      },
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: isBoarded ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(39, 101, 124, 0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isBoarded ? AppTheme.tertiaryContainer : AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isBoarded ? AppTheme.tertiaryContainer : AppTheme.surfaceVariant,
                    width: 2,
                  ),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: isBoarded
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppTheme.tertiary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.white),
                      )
                    : (initials != null
                        ? Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : null),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isBoarded ? AppTheme.tertiaryContainer : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBoarded ? Icons.check : Icons.schedule,
                      size: 14,
                      color: isBoarded ? AppTheme.onTertiaryContainer : AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBoarded ? 'Abordado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isBoarded ? AppTheme.onTertiaryContainer : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 8.0), // Above bottom nav
      child: FloatingActionButton.extended(
        onPressed: () {
          context.go('/chofer/scan');
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.qr_code_scanner, color: AppTheme.onPrimary),
        label: const Text(
          'Escanear QR',
          style: TextStyle(
            color: AppTheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        elevation: 8,
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
          _buildNavItem(Icons.route, 'Viajes', false, () {
            context.go('/chofer');
          }),
          _buildNavItem(Icons.qr_code_scanner, 'Escanear', false, () {
            context.go('/chofer/scan');
          }),
          _buildNavItem(Icons.group, 'Pasajeros', true, () {}),
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