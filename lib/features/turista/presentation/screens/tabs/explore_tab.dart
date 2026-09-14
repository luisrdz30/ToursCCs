import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/theme/app_theme.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    // For development without Auth
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final String name = data?['name'] ?? 'Explorer';
            final int points = data?['totalPoints'] ?? 0;
            final String mascot = data?['currentMascot'] ?? 'León Marino';

            return CustomScrollView(
              slivers: [
                _buildAppBar(name, points),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildGreeting(name, mascot),
                      const SizedBox(height: 24),
                      _buildBentoGrid(context),
                      const SizedBox(height: 32),
                      _buildFeaturedExperiences(context),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(String name, int points) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.surface.withOpacity(0.9),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceContainerHighest,
            ),
            child: const Icon(Icons.person, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Text(
            'Turismo AI',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryContainer.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: AppTheme.primary, size: 20),
              const SizedBox(width: 4),
              Text(
                '$points pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(String name, String mascot) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceContainerHighest,
            border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.pets, size: 40, color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${name.split(' ').first}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Listo para tu próxima aventura?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildBentoItem('Safe Taxi', 'Taxis verificados', Icons.local_taxi, AppTheme.secondaryContainer, AppTheme.onSecondaryContainer)),
            const SizedBox(width: 16),
            Expanded(child: _buildBentoItem('Metro Map', 'Rutas en vivo', Icons.subway, AppTheme.tertiaryContainer, AppTheme.onTertiaryContainer)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación Actual',
                    style: TextStyle(color: AppTheme.onPrimary.withOpacity(0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '24°C, Soleado',
                    style: TextStyle(color: AppTheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.onPrimary.withOpacity(0.9), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Quito, Ecuador',
                        style: TextStyle(color: AppTheme.onPrimary.withOpacity(0.9), fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.light_mode, color: AppTheme.onPrimary, size: 64),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoItem(String title, String subtitle, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.onSurface)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildFeaturedExperiences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Experiencias Destacadas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver Todo', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tours').limit(2).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final tours = snapshot.data!.docs;
            if (tours.isEmpty) return const Text('No hay tours disponibles.');

            return Column(
              children: tours.map((doc) {
                final t = doc.data() as Map<String, dynamic>;
                return _buildTourCard(
                  t['title'] ?? 'Tour',
                  t['durationMinutes']?.toString() ?? '120',
                  t['imageUrl'] ?? 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTourCard(String title, String duration, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurface.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Cultura', style: TextStyle(color: AppTheme.onPrimary, fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text('$duration min', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
