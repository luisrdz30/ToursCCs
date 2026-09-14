import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminEditTourScreen extends StatelessWidget {
  const AdminEditTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Partner Portal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        centerTitle: true,
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
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: AppTheme.onSurfaceVariant),
                      SizedBox(width: 4),
                      Text('Back to tours', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Edit Tour',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                    label: const Text('Delete\nTour', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('tours').doc(widget.tour.id).update({
                        'isActive': true, // Mock update
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.save_outlined, color: AppTheme.onPrimary),
                    label: const Text('Save\nChanges', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Cover Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Recommended size:\n1200x800px', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 16, color: AppTheme.onSurface),
                      label: const Text('Change', style: TextStyle(color: AppTheme.onSurface)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerLowest,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Información Básica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Título del Tour'),
            _buildTextField(initialValue: 'Gran Tour por Quito'),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Categoría'),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: 'Cultural',
                  items: const [
                    DropdownMenuItem(value: 'Cultural', child: Text('Cultural')),
                    DropdownMenuItem(value: 'Naturaleza', child: Text('Naturaleza')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Duración (Horas)'),
            _buildTextField(initialValue: '8'),
            const SizedBox(height: 16),
            
            _buildFieldLabel('Descripción'),
            _buildTextField(
              initialValue: 'Descubre la magia de la capital ecuatoriana en este recorrido completo. Desde las maravillas coloniales del Centro Histórico hasta el monumento de la Mitad del Mundo...',
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Paradas del Itinerario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppTheme.tertiaryContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: AppTheme.tertiary, size: 20),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildItineraryStop(1, 'Centro Histórico', 'Explore the best-preserved...'),
            const SizedBox(height: 12),
            _buildItineraryStop(2, 'Mitad del Mundo', 'Stand on the equator line and visit...'),
            const SizedBox(height: 32),
            
            const Text('Estado y Visibilidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Listado Activo', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                    Text('Visible para usuarios en la app', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                Switch(value: true, onChanged: (val) {}, activeColor: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Precio Base (USD)'),
            _buildTextField(initialValue: '\$ 45.00'),
            const SizedBox(height: 32),
            
            const Text('Logística', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            const SizedBox(height: 16),
            _buildFieldLabel('Tamaño Máximo Grupo'),
            _buildTextField(initialValue: '15'),
            const SizedBox(height: 16),
            _buildFieldLabel('Punto de Encuentro'),
            _buildTextField(initialValue: 'Plaza Grande, Old Town'),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({String? initialValue, TextEditingController? controller, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildItineraryStop(int index, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: AppTheme.tertiary),
                    const SizedBox(width: 16),
                    Icon(Icons.delete_outline, size: 16, color: AppTheme.error.withValues(alpha: 0.7)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
