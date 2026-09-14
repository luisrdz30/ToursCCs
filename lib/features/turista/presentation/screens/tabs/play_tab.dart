import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'Play & Collect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gana puntos, desbloquea cromos culturales y pasa el tiempo con nuestros juegos.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildDailyChallenge(context),
              const SizedBox(height: 24),
              _buildOtherGames(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 16,
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border.all(color: AppTheme.primaryContainer.withOpacity(0.2)),
            ),
            child: const Text(
              '¡Hola! ¿Listo para ganar algunos cromos hoy?',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: AppTheme.onErrorContainer, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'RETO DIARIO',
                  style: TextStyle(
                    color: AppTheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Wordle Cultural Ecuatoriano',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adivina la palabra local de hoy en 6 intentos para ganar un cromo único. ¡Pon a prueba tu jerga ecuatoriana!',
            style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/turista/wordle');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Reto'),
              ),
              const SizedBox(width: 16),
              const Row(
                children: [
                  Icon(Icons.timer, size: 16, color: AppTheme.secondary),
                  SizedBox(width: 4),
                  Text('24h Restantes', style: TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherGames() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildGameCard('Trivias GPS', 'Juega mientras llegas a tu destino', Icons.location_on, AppTheme.tertiary),
        _buildGameCard('Dominó', 'Clásico juego de mesa', Icons.grid_view, AppTheme.secondary),
        _buildGameCard('Sudoku', 'Rompecabezas numérico', Icons.apps, AppTheme.onSurfaceVariant),
        _buildGameCard('Solitario', 'Cartas para pasar el rato', Icons.style, AppTheme.primary),
      ],
    );
  }

  Widget _buildGameCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}
