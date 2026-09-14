import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/services/database_seeder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/theme/app_theme.dart';

class AdminContentTab extends StatelessWidget {
  const AdminContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Gestión de Contenido',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/admin/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Juegos y Recursos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube palabras para el Wordle, cromos para el álbum, y enlaza historias o videos a los tours.',
              style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            _buildFeatureCard(
              context,
              icon: Icons.grid_on,
              title: 'Wordle Cultural',
              description: 'Gestiona las palabras del día, pistas y recompensas para el minijuego.',
              color: const Color(0xFF6AAB9C), // Verde Wordle
              onTap: () {
                context.push('/admin/wordle');
              },
            ),
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              context,
              icon: Icons.collections_bookmark_outlined,
              title: 'Álbum de Cromos',
              description: 'Gestiona los cromos digitales que los turistas obtienen al escanear QR en tours o negocios.',
              color: const Color(0xFFE5A93D), // Dorado
              onTap: () {
                context.push('/admin/stickers');
              },
            ),
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              context,
              icon: Icons.menu_book_outlined,
              title: 'Historias y Multimedia',
              description: 'Vincula cómics, audios y videos de YouTube a tours o ubicaciones específicas.',
              color: const Color(0xFF5A4FCF), // Púrpura oscuro
              onTap: () {
                context.push('/admin/multimedia');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _seedData(context),
        label: const Text('Generar Datos'),
        icon: const Icon(Icons.auto_awesome),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _seedData(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando datos...')));
      final seeder = DatabaseSeeder();
      await seeder.seedAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos generados exitosamente. (Recarga la pantalla)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar: $e')),
        );
      }
    }
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
