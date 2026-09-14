import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          'Partner Portal',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gestión de\nTours',
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
                  label: const Text('Add\nNew', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(Icons.flag_outlined, '12', 'Active Tours', AppTheme.tertiary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(Icons.group_outlined, '340', 'Monthly Guests', AppTheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Existing Tours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
            const SizedBox(height: 16),
            _buildTourCard(
              context: context,
              tour: TourDto(
                id: '1',
                title: 'Tour Histórico',
                description: 'Explore the colonial...',
                durationMinutes: 180,
                price: 0,
                isActive: true,
                imageUrl: 'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?q=80&w=200&auto=format&fit=crop',
              ),
            ),
            const SizedBox(height: 16),
            _buildTourCard(
              context: context,
              tour: TourDto(
                id: '2',
                title: 'Gran Tour por Quito',
                description: 'Full day...',
                durationMinutes: 480,
                price: 0,
                isActive: true,
                imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=200&auto=format&fit=crop',
              ),
            ),
            const SizedBox(height: 16),
            _buildTourCard(
              context: context,
              tour: TourDto(
                id: '3',
                title: 'Gastronomy Walk',
                description: 'Local markets and...',
                durationMinutes: 240,
                price: 0,
                isActive: false,
                imageUrl: '',
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard({
    required BuildContext context,
    required TourDto tour,
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
                    Text('${tour.durationMinutes ~/ 60} horas', style: const TextStyle(fontSize: 10, color: AppTheme.tertiary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  context.push('/admin/edit-tour', extra: tour);
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
                  isDraft ? 'Borrador' : 'Activo',
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
