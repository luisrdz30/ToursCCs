import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminPromoReviewScreen extends StatelessWidget {
  const AdminPromoReviewScreen({super.key});

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 16, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Revisión de Evento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(39, 101, 124, 0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?q=80&w=600&auto=format&fit=crop',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Experiencia Premium', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Noche de Tapas y\nFlamenco Bajo las\nEstrellas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.calendar_month, 'FECHA Y HORA', '15 de Noviembre\n19:00 - 22:30 Hrs'),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.location_on, 'UBICACIÓN', 'Terraza El Mirador\nCentro Histórico, Sevilla'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.description_outlined, color: AppTheme.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Descripción del Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Únete a nosotros para una noche inolvidable celebrando la cultura local. Disfruta de una selección exclusiva de tapas preparadas por nuestro chef ejecutivo, acompañadas de vinos regionales seleccionados. La velada estará amenizada por un espectáculo íntimo de flamenco tradicional en nuestra terraza panorámica con vistas a la ciudad iluminada.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_offer_outlined, color: AppTheme.onTertiaryContainer),
                      SizedBox(width: 8),
                      Text(
                        'Oferta Especial Incluida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOfferItem('Cóctel de bienvenida de cortesía'),
                  const SizedBox(height: 8),
                  _buildOfferItem('Asientos preferenciales en primera fila'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Acciones de Aprobación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa los detalles y toma una decisión sobre esta solicitud de evento.',
              style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ej. La imagen de portada necesita mayor resolución, o el título excede la longitud recomendada...',
                hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppTheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios solicitados')));
                  context.pop();
                },
                icon: const Icon(Icons.edit_note, color: AppTheme.primary),
                label: const Text('Solicitar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento aprobado')));
                  context.pop();
                },
                icon: const Icon(Icons.check_circle_outline, color: AppTheme.onPrimary),
                label: const Text('Aprobar', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'ID de Solicitud: #EVT-2023-8891',
                style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOfferItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.onTertiaryContainer),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.onTertiaryContainer, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
