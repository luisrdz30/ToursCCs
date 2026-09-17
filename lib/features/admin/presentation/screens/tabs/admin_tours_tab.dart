import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/models/tour_dto.dart';

class AdminToursTab extends StatelessWidget {
  const AdminToursTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: const Icon(Icons.storefront, color: AppTheme.primary),
        title: const Text(
          'Gestión de Tours',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Todos los\nTours',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/admin/add-tour');
                  },
                  icon: const Icon(Icons.add, color: AppTheme.onPrimary, size: 16),
                  label: const Text('Crear\nNuevo', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tours').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay tours registrados', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                  );
                }

                final tours = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return TourDto.fromJson(data, id: doc.id);
                }).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tours.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return _buildTourCard(context: context, tour: tour, rawData: snapshot.data!.docs[index].data() as Map<String, dynamic>);
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCard({
    required BuildContext context,
    required TourDto tour,
    required Map<String, dynamic> rawData,
  }) {
    final bool isDraft = !tour.isActive;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(39, 101, 124, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              image: (tour.imageUrl != null && tour.imageUrl!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(tour.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (tour.imageUrl == null || tour.imageUrl!.isEmpty) 
                ? const Icon(Icons.map, color: AppTheme.onSurfaceVariant) 
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  tour.description,
                  style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppTheme.tertiary),
                    const SizedBox(width: 4),
                    Text('${(tour.durationMinutes / 60).toStringAsFixed(1)} horas', style: const TextStyle(fontSize: 10, color: AppTheme.tertiary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  rawData['id'] = tour.id;
                  context.push('/admin/edit-tour', extra: rawData);
                },
                icon: const Icon(Icons.edit, color: AppTheme.tertiary, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.tertiaryContainer.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDraft ? AppTheme.surfaceContainer : AppTheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDraft ? 'Inactivo' : 'Activo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDraft ? AppTheme.onSurfaceVariant : AppTheme.secondary,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
