import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'tabs/explore_tab.dart';
import 'tabs/travel_tab.dart';
import 'tabs/pass_tab.dart';
import 'tabs/play_tab.dart';
import 'tabs/journey_tab.dart';

class TuristaMainScreen extends StatefulWidget {
  const TuristaMainScreen({super.key});

  @override
  State<TuristaMainScreen> createState() => _TuristaMainScreenState();
}

class _TuristaMainScreenState extends State<TuristaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ExploreTab(),
    const TravelTab(),
    const PassTab(),
    const PlayTab(),
    const JourneyTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.explore, 'Explore'),
                _buildNavItem(1, Icons.map_outlined, 'Travel'),
                _buildQRItem(2),
                _buildNavItem(3, Icons.sports_esports_outlined, 'Play'),
                _buildNavItem(4, Icons.route_outlined, 'Journey'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant;
    
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRItem(int index) {
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, color: AppTheme.onPrimary, size: 28),
            const SizedBox(height: 2),
            Text(
              'Pass',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
