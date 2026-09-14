import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'tabs/negocio_dashboard_tab.dart';
import 'tabs/negocio_promos_tab.dart';
import 'tabs/negocio_profile_tab.dart';

class NegocioMainScreen extends StatefulWidget {
  const NegocioMainScreen({super.key});

  @override
  State<NegocioMainScreen> createState() => _NegocioMainScreenState();
}

class _NegocioMainScreenState extends State<NegocioMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    NegocioDashboardTab(onTabChange: (index) {
      setState(() {
        _currentIndex = index;
      });
    }),
    const NegocioPromosTab(),
    const NegocioProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _tabs[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 78, 100, 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.storefront, 'Negocio'),
            _buildNavItem(1, Icons.local_activity_outlined, 'Promos'),
            _buildNavItem(2, Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.onPrimary : AppTheme.secondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
